"""Home dashboard catalog tables.

Revision ID: 0003_home
Revises: 0002_assessment
Create Date: 2026-08-03
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0003_home"
down_revision: Union[str, None] = "0002_assessment"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_TS = sa.Column(
    "created_at",
    sa.DateTime(timezone=True),
    server_default=sa.text("(CURRENT_TIMESTAMP)"),
    nullable=False,
)
_TS2 = sa.Column(
    "updated_at",
    sa.DateTime(timezone=True),
    server_default=sa.text("(CURRENT_TIMESTAMP)"),
    nullable=False,
)


def upgrade() -> None:
    op.create_table(
        "home_categories",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("code", sa.String(64), nullable=False),
        sa.Column("label", sa.String(120), nullable=False),
        sa.Column("icon_key", sa.String(64), nullable=False),
        sa.Column("sort_order", sa.Integer(), nullable=False),
        sa.Column("is_default_selected", sa.Boolean(), nullable=False),
        _TS,
        _TS2,
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_home_categories_code", "home_categories", ["code"], unique=True)

    op.create_table(
        "home_featured_workouts",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("code", sa.String(64), nullable=False),
        sa.Column("title", sa.String(255), nullable=False),
        sa.Column("subtitle", sa.String(255), nullable=False),
        sa.Column("duration_minutes", sa.Integer(), nullable=False),
        sa.Column("calories", sa.Integer(), nullable=False),
        sa.Column("image_url", sa.String(512), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("(CURRENT_TIMESTAMP)"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("(CURRENT_TIMESTAMP)"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_home_featured_workouts_code", "home_featured_workouts", ["code"], unique=True)

    op.create_table(
        "home_featured_meals",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("code", sa.String(64), nullable=False),
        sa.Column("title", sa.String(255), nullable=False),
        sa.Column("calories", sa.Integer(), nullable=False),
        sa.Column("duration_minutes", sa.Integer(), nullable=False),
        sa.Column("protein_g", sa.Integer(), nullable=False),
        sa.Column("fats_g", sa.Integer(), nullable=False),
        sa.Column("image_url", sa.String(512), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("(CURRENT_TIMESTAMP)"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("(CURRENT_TIMESTAMP)"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_home_featured_meals_code", "home_featured_meals", ["code"], unique=True)

    op.create_table(
        "home_activity_blob_layouts",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("hours_label", sa.String(32), nullable=False),
        sa.Column("color_hex", sa.String(16), nullable=False),
        sa.Column("rotation_deg", sa.Float(), nullable=False),
        sa.Column("width_factor", sa.Float(), nullable=False),
        sa.Column("height_factor", sa.Float(), nullable=False),
        sa.Column("align_x", sa.Float(), nullable=False),
        sa.Column("align_y", sa.Float(), nullable=False),
        sa.Column("sort_order", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("(CURRENT_TIMESTAMP)"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("(CURRENT_TIMESTAMP)"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_table(
        "home_ai_coach_card",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("conversations_count", sa.Integer(), nullable=False),
        sa.Column("subtitle", sa.String(255), nullable=False),
        sa.Column("image_url", sa.String(512), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("(CURRENT_TIMESTAMP)"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("(CURRENT_TIMESTAMP)"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )


def downgrade() -> None:
    op.drop_table("home_ai_coach_card")
    op.drop_table("home_activity_blob_layouts")
    op.drop_table("home_featured_meals")
    op.drop_table("home_featured_workouts")
    op.drop_table("home_categories")
