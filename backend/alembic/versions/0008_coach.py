"""Coach conversations and messages.

Revision ID: 0008_coach
Revises: 0007_activities
Create Date: 2026-08-03
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0008_coach"
down_revision: Union[str, None] = "0007_activities"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "coach_conversations",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("title", sa.String(255), nullable=False),
        sa.Column("model", sa.String(64), nullable=False),
        sa.Column("tab", sa.String(32), nullable=False),
        sa.Column("subtitle", sa.String(255), nullable=False),
        sa.Column("icon_key", sa.String(64), nullable=False),
        sa.Column("color_hex", sa.String(16), nullable=False),
        sa.Column("badge", sa.String(16), nullable=True),
        sa.Column("total_label", sa.String(64), nullable=False),
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
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_coach_conversations_user_id", "coach_conversations", ["user_id"])
    op.create_index("ix_coach_conversations_tab", "coach_conversations", ["tab"])

    op.create_table(
        "coach_messages",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("conversation_id", sa.Uuid(), nullable=False),
        sa.Column("kind", sa.String(32), nullable=False),
        sa.Column("text", sa.Text(), nullable=False),
        sa.Column("selected", sa.Boolean(), nullable=False),
        sa.Column("card_title", sa.String(255), nullable=True),
        sa.Column("card_subtitle", sa.String(255), nullable=True),
        sa.Column("tags_csv", sa.String(512), nullable=True),
        sa.Column("sent_at", sa.DateTime(timezone=True), nullable=False),
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
        sa.ForeignKeyConstraint(
            ["conversation_id"],
            ["coach_conversations.id"],
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_coach_messages_conversation_id",
        "coach_messages",
        ["conversation_id"],
    )


def downgrade() -> None:
    op.drop_table("coach_messages")
    op.drop_table("coach_conversations")
