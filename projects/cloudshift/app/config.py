from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "CloudShift"
    app_env: str = "local"
    cors_origins: str = "http://localhost:3000"
    log_level: str = "INFO"

    shipping_base_url: str = "http://shipping:9000"
    shipping_timeout_seconds: float = 1.0
    shipping_api_token: str = "cloudshift-demo-token"

    scenario_bad_http_status: bool = False

    firestore_enabled: bool = False
    firestore_project_id: str = "cloudshift-local"
    firestore_database: str = "(default)"
    audit_collection: str = "audit_events"
    db_pool_size: int = 5
    db_max_overflow: int = 10
    db_pool_timeout: float = 30.0
    db_test_delay_seconds: float = 0.0

    db_host: str = "db"
    db_port: int = 5432
    db_name: str = "cloudshift"
    db_user: str = "cloudshift"
    db_password: str = "cloudshift_dev"
    instance_unix_socket: str | None = None

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def database_url(self) -> str:
        return (
            f"postgresql+psycopg://{self.db_user}:{self.db_password}"
            f"@{self.db_host}:{self.db_port}/{self.db_name}"
        )


settings = Settings()
