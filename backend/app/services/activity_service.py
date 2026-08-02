from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException, ValidationAppException
from app.models.activity import Activity, ActivityType
from app.repositories.activity_repository import ActivityRepository
from app.schemas.activity import (
    ActivityCompleteOut,
    ActivityCompleteRequest,
    ActivityCreateRequest,
    ActivityOut,
    ActivityStatusItemOut,
    ActivityStatusOut,
    ActivityTypeOut,
    DirectionsOut,
    DonutSegmentOut,
)

CDN = "https://cdn.uplift.ai"


class ActivityService:
    def __init__(self) -> None:
        self.activities = ActivityRepository()

    async def get_status(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> ActivityStatusOut:
        rows = await self.activities.list_for_user(session, user_id)
        has_any = len(rows) > 0
        return ActivityStatusOut(
            items=self._status_items(),
            has_activities=has_any,
        )

    def _status_items(self) -> list[ActivityStatusItemOut]:
        return [
            ActivityStatusItemOut(
                label="Running",
                hours_label="68h",
                color_hex="#000000",
                rotation_deg=40,
                width=140,
                height=170,
                dx=0.05,
                dy=0.1,
            ),
            ActivityStatusItemOut(
                label="Yoga",
                hours_label="87h",
                color_hex="#EBEBEB",
                rotation_deg=-25,
                width=130,
                height=160,
                dx=-0.15,
                dy=-0.05,
            ),
            ActivityStatusItemOut(
                label="Weightlifting",
                hours_label="15h",
                color_hex="#2962FF",
                rotation_deg=15,
                width=100,
                height=110,
                dx=0.55,
                dy=0.45,
            ),
            ActivityStatusItemOut(
                label="Jogging",
                hours_label="1h",
                color_hex="#FF7A21",
                rotation_deg=-40,
                width=80,
                height=90,
                dx=0.5,
                dy=-0.55,
            ),
            ActivityStatusItemOut(
                label="Biking",
                hours_label="7h",
                color_hex="#FF4B4B",
                rotation_deg=-70,
                width=75,
                height=85,
                dx=-0.55,
                dy=-0.45,
            ),
        ]

    def get_directions(self) -> DirectionsOut:
        return DirectionsOut(
            address="3 Birrel Avenue",
            instruction="Turn right",
            distance_left="10 Mtr Left",
            arrival_label="Arrival ( 2 mins )",
            thumbnail_url=f"{CDN}/workouts/strength-header.png",
        )

    async def create_activity(
        self,
        session: AsyncSession,
        user_id: UUID,
        body: ActivityCreateRequest,
    ) -> ActivityOut:
        now = datetime.now(UTC)
        saved = await self.activities.add(
            session,
            Activity(
                user_id=user_id,
                type=ActivityType(body.type.value),
                title=body.title or body.type.value.title(),
                started_at=now,
            ),
        )
        return self._to_out(saved)

    async def complete_activity(
        self,
        session: AsyncSession,
        user_id: UUID,
        activity_id: UUID,
        body: ActivityCompleteRequest,
    ) -> ActivityCompleteOut:
        activity = await self.activities.get_for_user(session, activity_id, user_id)
        if activity is None:
            raise NotFoundException("Activity not found")
        if activity.ended_at is not None:
            raise ValidationAppException("Activity already completed")
        now = datetime.now(UTC)
        activity.ended_at = now
        activity.distance_m = body.distance_m if body.distance_m is not None else 3200.0
        activity.calories = body.calories if body.calories is not None else 254
        activity.avg_bpm = body.avg_bpm if body.avg_bpm is not None else 130
        await session.flush()
        await session.refresh(activity)
        label = (activity.title or activity.type.value).title()
        return ActivityCompleteOut(
            activity=self._to_out(activity),
            title=f"{label} Completed",
            segments=self._complete_segments(),
            suggestion_title="Post Jogging Stretch",
            suggestion_subtitle="+12 More AI Suggestions",
        )

    def _complete_segments(self) -> list[DonutSegmentOut]:
        return [
            DonutSegmentOut(label="Distance", percent=26, color_hex="#FF9547"),
            DonutSegmentOut(label="Calorie", percent=24, color_hex="#A283F1"),
            DonutSegmentOut(label="BPM", percent=54, color_hex="#3F3F3F"),
        ]

    def _to_out(self, activity: Activity) -> ActivityOut:
        return ActivityOut(
            id=activity.id,
            type=ActivityTypeOut(activity.type.value),
            title=activity.title,
            started_at=activity.started_at,
            ended_at=activity.ended_at,
            distance_m=activity.distance_m,
            calories=activity.calories,
            avg_bpm=activity.avg_bpm,
        )
