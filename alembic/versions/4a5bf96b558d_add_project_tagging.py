"""Add project tagging

Revision ID: 4a5bf96b558d
Revises: 5002e75c0604
Create Date: 2016-06-02 23:42:17.332659

"""

# revision identifiers, used by Alembic.
revision = '4a5bf96b558d'
down_revision = '5002e75c0604'

from alembic import op
import sqlalchemy as sa


def upgrade():
    tags_table = op.create_table(
        'tags',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('name', sa.Unicode),
        sa.Column('admin_description', sa.Unicode),
    )


    tag_translation_table = op.create_table(
        'tags_translations',
        sa.Column('id', sa.Integer, nullable=False),
        sa.Column('locale', sa.String(10), nullable=False),
        sa.Column('spotlight_text', sa.String),
        sa.UniqueConstraint('id', 'locale'),
        sa.ForeignKeyConstraint(['id'], ['tags.id'], ondelete="CASCADE")
    )


    project_tags_table = op.create_table(
        'project_tags',
        sa.Column('project', sa.Integer),
        sa.Column('tag', sa.Integer),
        sa.ForeignKeyConstraint(['project'], ['project.id']),
        sa.ForeignKeyConstraint(['tag'], ['tags.id'])
    )


def downgrade():
    op.drop_table('project_tags')
    op.drop_table('tags_translations')
    op.drop_table('tags')
