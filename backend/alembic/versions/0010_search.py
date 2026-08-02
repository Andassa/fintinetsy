"""Search catalog items.

Revision ID: 0010_search
Revises: 0009_settings
Create Date: 2026-08-03
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0010_search"
down_revision: Union[str, None] = "0009_settings"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "search_catalog_items",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("code", sa.String(64), nullable=False),
        sa.Column("title", sa.String(255), nullable=False),
        sa.Column("kind", sa.String(32), nullable=False),
        sa.Column("filter", sa.String(32), nullable=True),
        sa.Column("match_percent", sa.Integer(), nullable=False),
        sa.Column("icon_key", sa.String(64), nullable=False),
        sa.Column("icon_color_hex", sa.String(16), nullable=False),
        sa.Column("badge", sa.String(16), nullable=True),
        sa.Column("progress", sa.Float(), nullable=True),
        sa.Column("checked", sa.Boolean(), nullable=False),
        sa.Column("sort_order", sa.Integer(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("(CURRENT_TIMESTAMP)"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("(CURRENT_TIMESTAMP)"),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_search_catalog_items_code", "search_catalog_items", ["code"], unique=True)


def downgrade() -> None:
    op.drop_table("search_catalog_items")
