"""add overpass to project

Revision ID: 40d0f2b07d22
Revises: 1bdc819ae210
Create Date: 2017-08-03 23:55:01.541405

"""

# revision identifiers, used by Alembic.
revision = '40d0f2b07d22'
down_revision = '1bdc819ae210'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('project', sa.Column('overpass', sa.Unicode(), nullable=True))


def downgrade():
    op.drop_column('project', 'overpass')
