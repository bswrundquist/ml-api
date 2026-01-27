"""Pytest fixtures and configuration."""
import pytest
import asyncio
from typing import AsyncGenerator, Generator

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from fastapi.testclient import TestClient

from app.core.config import settings
from app.db.base import Base
from app.main import app
from app.db.session import get_db


# Test database URL
TEST_DATABASE_URL = "postgresql+asyncpg://mlapi:mlapi@localhost:5432/mlapi_test"


@pytest.fixture(scope="session")
def event_loop() -> Generator:
    """Create event loop for async tests."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session")
async def test_engine():
    """Create test database engine."""
    engine = create_async_engine(
        TEST_DATABASE_URL,
        echo=False,
        future=True,
    )

    # Create tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    yield engine

    # Drop tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()


@pytest.fixture
async def test_db(test_engine) -> AsyncGenerator[AsyncSession, None]:
    """Create test database session."""
    async_session = async_sessionmaker(
        test_engine,
        class_=AsyncSession,
        expire_on_commit=False,
    )

    async with async_session() as session:
        yield session
        await session.rollback()


@pytest.fixture
def test_client(test_db) -> TestClient:
    """Create test client with database override."""

    async def override_get_db():
        yield test_db

    app.dependency_overrides[get_db] = override_get_db

    with TestClient(app) as client:
        yield client

    app.dependency_overrides.clear()


@pytest.fixture
def fake_gcs_client():
    """Create fake in-memory GCS client for testing."""

    class FakeGCSClient:
        """Fake GCS client that stores data in memory."""

        def __init__(self):
            self.storage = {}
            self.bucket_name = "test-bucket"

        def upload_bytes(self, blob_path: str, data: bytes, content_type: str = None) -> str:
            self.storage[blob_path] = data
            return f"gs://{self.bucket_name}/{blob_path}"

        def upload_file(self, blob_path: str, file_path: str, content_type: str = None) -> str:
            with open(file_path, "rb") as f:
                data = f.read()
            self.storage[blob_path] = data
            return f"gs://{self.bucket_name}/{blob_path}"

        def download_bytes(self, blob_path: str) -> bytes:
            if blob_path not in self.storage:
                raise Exception(f"Blob not found: {blob_path}")
            return self.storage[blob_path]

        def download_to_file(self, blob_path: str, file_path: str) -> None:
            data = self.download_bytes(blob_path)
            with open(file_path, "wb") as f:
                f.write(data)

        def upload_json(self, blob_path: str, data: dict) -> str:
            import json
            json_bytes = json.dumps(data).encode("utf-8")
            return self.upload_bytes(blob_path, json_bytes, "application/json")

        def download_json(self, blob_path: str) -> dict:
            import json
            data = self.download_bytes(blob_path)
            return json.loads(data.decode("utf-8"))

        def exists(self, blob_path: str) -> bool:
            return blob_path in self.storage

        def delete(self, blob_path: str) -> None:
            if blob_path in self.storage:
                del self.storage[blob_path]

        def list_blobs(self, prefix: str) -> list[str]:
            return [path for path in self.storage.keys() if path.startswith(prefix)]

        def verify_connectivity(self) -> bool:
            return True

    return FakeGCSClient()


@pytest.fixture
def sample_classification_data():
    """Sample classification dataset."""
    return [
        {"age": 25, "income": 50000, "tenure_months": 6, "churned": 0},
        {"age": 35, "income": 75000, "tenure_months": 24, "churned": 1},
        {"age": 45, "income": 90000, "tenure_months": 36, "churned": 0},
        {"age": 28, "income": 55000, "tenure_months": 12, "churned": 1},
        {"age": 52, "income": 120000, "tenure_months": 48, "churned": 0},
        {"age": 30, "income": 60000, "tenure_months": 18, "churned": 0},
        {"age": 38, "income": 80000, "tenure_months": 30, "churned": 1},
        {"age": 42, "income": 95000, "tenure_months": 42, "churned": 0},
    ]


@pytest.fixture
def sample_regression_data():
    """Sample regression dataset."""
    return [
        {"day_of_week": 1, "month": 1, "promo_active": 0, "sales_amount": 1000.5},
        {"day_of_week": 2, "month": 1, "promo_active": 1, "sales_amount": 1500.2},
        {"day_of_week": 3, "month": 1, "promo_active": 0, "sales_amount": 1100.8},
        {"day_of_week": 4, "month": 1, "promo_active": 1, "sales_amount": 1600.3},
        {"day_of_week": 5, "month": 1, "promo_active": 0, "sales_amount": 1200.1},
        {"day_of_week": 6, "month": 1, "promo_active": 1, "sales_amount": 2000.9},
        {"day_of_week": 7, "month": 1, "promo_active": 1, "sales_amount": 2200.4},
    ]


@pytest.fixture
def sample_split_params():
    """Sample split parameters."""
    return {
        "train_ratio": 0.7,
        "val_ratio": 0.15,
        "test_ratio": 0.15,
        "seed": 42,
    }
