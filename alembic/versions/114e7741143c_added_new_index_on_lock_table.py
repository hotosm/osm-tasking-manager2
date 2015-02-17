"""Added new index on lock table

Revision ID: 114e7741143c
Revises: 3f282468e66e
Create Date: 2014-08-21 15:50:43.192336

"""

# revision identifiers, used by Alembic.
revision = '114e7741143c'
down_revision = '3f282468e66e'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_index('ix_task_lock_project_id', 'task_lock', ['project_id'], unique=False)


def downgrade():
    op.drop_index('ix_task_lock_project_id', table_name='task_lock')
