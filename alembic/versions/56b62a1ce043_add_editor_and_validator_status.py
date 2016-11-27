"""Add editor and validator status

Revision ID: 56b62a1ce043
Revises: 5002e75c0604
Create Date: 2016-11-27 11:29:58.757273

"""

# revision identifiers, used by Alembic.
revision = '56b62a1ce043'
down_revision = '5002e75c0604'

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('users', sa.Column('editor_status', sa.Integer))
    op.add_column('users', sa.Column('validator_status', sa.Integer))


def downgrade():
    op.drop_column('users', 'editor_status')
    op.drop_column('users', 'validator_status')
