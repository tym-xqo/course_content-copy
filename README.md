# Copy course_content table between environments

`course_content-copy.sh` is a script that uses a `copy` statement to write the contents of `ai_tutor` database `course_content` table from a source database to a target on another server. It assumes that data is in the desired schema on the source, and that on the target the table needs to dropped and recreated. The script takes care of all steps and is self-contained with no dependencies. Postgres databases at BenchPrep are only reachable at private IPs, so this script needs to be run from inside the IBM network. 

To run this in a pod:

1. Start your pod the usual way: `cd $PROJECT_DIR/infrastructure; rake pod:create`
1. From in your pod, clone this repe and cd into it: `git clone https://github.com/tym-xqo/course_content-copy.git; cd course_content-copy`
1. Edit lines below the `CONFIGURE` comment as needed (ie to choose source and target based on URLs provided)
2. Copy .pgpass.example to `.pgpass` and restrict access to current user: `cp .pgpass.example .pgpass; chmod 0600 .pgpass`
3. Edit `.pgpass` to provide correct passwords from `ai_tutor_user` Postgres user (in 1Password)*
4. Execute the shell script: `bash course_content-copy.sh`
5. 🎉
