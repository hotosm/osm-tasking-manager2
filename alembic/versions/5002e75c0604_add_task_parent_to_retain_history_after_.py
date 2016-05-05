"""Add task parent to retain history after split

Revision ID: 5002e75c0604
Revises: 33e34b3beaa3
Create Date: 2016-05-10 22:37:31.383527

"""

# revision identifiers, used by Alembic.
revision = '5002e75c0604'
down_revision = '33e34b3beaa3'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('task', sa.Column('parent_id', sa.Integer(), nullable=True))

def downgrade():
    op.drop_column('task', 'parent_id')
