import json
import psycopg2
import click
import subprocess
import sys
import os

@click.group()
def app():
    pass

@app.command(help="Initializes the Terraform context")
@click.option("--conn-str", required=True, help="Connection string for PostgreSQL")
def init(conn_str):
    must(run_terraform(['init', '-no-color', '-input=false', f'-backend-config=conn_str={conn_str}']))

@app.command(help="Applies the configuration to the given workspace")
@click.argument("workspace")
def apply(workspace):
    ensure_workspace(workspace)
    must(run_terraform(['apply', '-auto-approve', '-no-color', '-input=false']))

@app.command(help="Destroys everything on given workspace")
@click.argument("workspace")
def destroy(workspace):
    ensure_workspace(workspace)
    must(run_terraform(['destroy']))

@app.command(help="Lists running workspaces with extended info")
def list():
    conn = psycopg2.connect(get_connection_string(), options=f'-c search_path=terraform_remote_state')
    cur = conn.cursor()
    cur.execute("select * from states;")

    for _, name, state_raw in cur.fetchall():
        state = json.loads(state_raw)
        if not bool(state['outputs']):
            continue

        print(name)
        print(f" Monitoring URL: https://{state['outputs']['monitoring_domain']['value']}/{state['outputs']['monitoring_secret']['value']}/")
        print(f" Admin URL: https://{state['outputs']['minecraft_admin_domain']['value']}/")
        print(f" Admin Password: {state['outputs']['minecraft_admin_password']['value']}")

    conn.close()

def ensure_workspace(workspace):
    run_terraform(['workspace', 'new', workspace], stdin=None, stderr=subprocess.PIPE)
    must(run_terraform(['workspace', 'select', workspace]))

def run_terraform(command, stdin=sys.stdin, stdout=sys.stdout, stderr=sys.stderr):
    terraform_env = os.environ.copy()
    terraform_env["TF_IN_AUTOMATION"] = "yes"
    return run(['terraform'] + command, path('config'), stdin, stdout, stderr, env=terraform_env)

def run(command, cwd, stdin, stdout, stderr, env=os.environ):
    process = subprocess.Popen(command,
        stdin=stdin,
        stdout=stdout, 
        stderr=stderr,
        env=env,
        cwd=cwd)
    process.wait()
    return process.returncode

def get_connection_string():
    pg_connection_string = ''
    with open(path('config', '.terraform', 'terraform.tfstate')) as reader:
        terraform_state = json.loads(reader.read())
        pg_connection_string = terraform_state['backend']['config']['conn_str']
    return pg_connection_string

def path(*args):
    return os.path.join(os.path.dirname(os.path.realpath(__file__)), *args)

def must(returncode):
    if returncode > 0:
        exit(returncode)

if __name__ == '__main__':
    app()
