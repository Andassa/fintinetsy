from fastapi import APIRouter, status

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.assessment import (
    AssessmentConfigOut,
    AssessmentProfileOut,
    AssessmentProfileUpdate,
    UserMeOut,
)
from app.services.assessment_service import AssessmentService

router = APIRouter(tags=["assessment"])
_service = AssessmentService()


@router.get("/assessment/config", response_model=AssessmentConfigOut)
async def get_assessment_config(session: DbSession) -> AssessmentConfigOut:
    return await _service.get_config(session)


@router.get("/users/me", response_model=UserMeOut)
async def get_me(user: CurrentUser) -> UserMeOut:
    return UserMeOut(
        id=str(user.id),
        email=user.email,
        name=user.name,
        avatar_url=user.avatar_url,
        membership=user.membership.value,
    )


@router.get("/users/me/assessment", response_model=AssessmentProfileOut)
async def get_my_assessment(
    session: DbSession,
    user: CurrentUser,
) -> AssessmentProfileOut:
    return await _service.get_or_create_profile(session, user.id)


@router.put(
    "/users/me/assessment",
    response_model=AssessmentProfileOut,
    status_code=status.HTTP_200_OK,
)
async def put_my_assessment(
    body: AssessmentProfileUpdate,
    session: DbSession,
    user: CurrentUser,
) -> AssessmentProfileOut:
    return await _service.update_profile(session, user.id, body)
