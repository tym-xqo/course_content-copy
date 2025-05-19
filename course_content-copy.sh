#!/usr/bin/env bash
# to be run inside IBM network
set -e
set -u
set -o pipefail
set -x


# database connections for all AI Tutor DBs
INTEGRATION_DBURL=postgresql://ai_tutor_user@10.169.203.61:5433/ai_tutor_integration
STAGING_DBURL=postgresql://ai_tutor_user@10.169.203.61:6433/ai_tutor_staging
PRODUCTION_DBURL=postgresql://ai_tutor_user@10.94.21.79:5433/ai_tutor_production

# CONFIGURE source and target
# TODO: for Prod move, update lines below for Staging as Source and Prod as target
SOURCE_DBURL=$INTEGRATION_DBURL
TARGET_DBURL=$STAGING_DBURL

# connect to Staging db and copy the data out of `course_content` to CSV
# psql -d $SOURCE_DBURL -e -c "\copy course_content to '/tmp/course_content.csv' with csv header delimiter '|'"

# # connect to Production, drop the old course_content table
# psql -d $TARGET_DBURL -e -c "drop table if exists course_content;"

# Heredoc fot the create statement assigned to variable
table_ddl="$(cat << EOF
create table if not exists course_content (
    tenant_id integer not null,
    content_package_title text not null,
    content_package_id bigint not null,
    content_type text not null,
    content_id bigint not null,
    name text,
    content_chunk text not null,
    content_sha text,
    html_content text not null,
    correct_answer text,
    parent_content_id bigint,
    created_at timestamp without time zone not null default current_timestamp
)
EOF
)"

# execute ^^^ on Production to recreate the table
psql -d $TARGET_DBURL -e -c "${table_ddl}"

# ensure `ai_tutor_role` owns the table, so `ai_tutor_user` can access it
psql -d $TARGET_DBURL -e -c "alter table course_content owner to ai_tutor_role"

# copy the data from Staging export into Prod
psql -d $TARGET_DBURL -e -c "\copy course_content from '/tmp/course_content.csv' with csv header delimiter '|'"

# w00t!
echo 'wow, done!'
