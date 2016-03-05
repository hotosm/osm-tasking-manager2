"""add import_url to task

Revision ID: 48e146fb224f
Revises: 4290a873fda7
Create Date: 2016-03-05 10:52:32.903384

"""

# revision identifiers, used by Alembic.
revision = '48e146fb224f'
down_revision = '4290a873fda7'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('task', sa.Column('import_url', sa.Unicode(), nullable=True))


def downgrade():
    op.drop_column('task', 'import_url')
