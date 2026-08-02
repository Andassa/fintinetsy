"""Assessment tables: fitness_goals, assessment_config, assessment_profiles.

Revision ID: 0002_assessment
Revises: 0001_auth
Create Date: 2026-08-03
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0002_assessment"
down_revision: Union[str, None] = "0001_auth"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "fitness_goals",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("code", sa.String(length=64), nullable=False),
        sa.Column("label", sa.String(length=255), nullable=False),
        sa.Column("icon_key", sa.String(length=64), nullable=False),
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
    op.create_index("ix_fitness_goals_code", "fitness_goals", ["code"], unique=True)

    op.create_table(
        "assessment_config",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("min_age", sa.Integer(), nullable=False),
        sa.Column("max_age", sa.Integer(), nullable=False),
        sa.Column("default_age", sa.Integer(), nullable=False),
        sa.Column("min_weight_kg", sa.Float(), nullable=False),
        sa.Column("max_weight_kg", sa.Float(), nullable=False),
        sa.Column("default_weight_kg", sa.Float(), nullable=False),
        sa.Column("fitness_labels_csv", sa.Text(), nullable=False),
        sa.Column("vocal_prompt", sa.Text(), nullable=False),
        sa.Column("vocal_highlighted_words", sa.String(length=255), nullable=False),
        sa.Column("vocal_subtitle", sa.Text(), nullable=False),
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

    op.create_table(
        "assessment_profiles",
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("age", sa.Integer(), nullable=True),
        sa.Column("weight_kg", sa.Float(), nullable=True),
        sa.Column("weight_unit", sa.String(length=8), nullable=False),
        sa.Column("fitness_level", sa.Integer(), nullable=False),
        sa.Column("gender", sa.String(length=16), nullable=True),
        sa.Column("goal_code", sa.String(length=64), nullable=True),
        sa.Column("avatar_id", sa.String(length=64), nullable=True),
        sa.Column("vocal_completed", sa.Boolean(), nullable=False),
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
        sa.ForeignKeyConstraint(["goal_code"], ["fitness_goals.code"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id"),
    )


def downgrade() -> None:
    op.drop_table("assessment_profiles")
    op.drop_table("assessment_config")
    op.drop_table("fitness_goals")
