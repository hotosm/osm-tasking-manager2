"""add maprules config id column

Revision ID: 3d4f41c21888
Revises: 1bdc819ae210
Create Date: 2018-10-11 18:36:52.735831

"""

# revision identifiers, used by Alembic.
revision = '3d4f41c21888'
down_revision = '1bdc819ae210'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('project', sa.Column('attribution_config_id', sa.Unicode(), nullable=True))


def downgrade():
    op.drop_column('project','attribution_config_id')

