import json
import psycopg2
import click

@click.group()
def app():
    pass

@app.command()
def list():
    conn = psycopg2.connect(get_connection_string())
    cur = conn.cursor()
    cur.execute("set search_path to terraform_remote_state; select * from states;")

    for _, name, state_raw in cur.fetchall():
        state = json.loads(state_raw)
        if not bool(state['outputs']):
            continue

        print(name)
        print(f" Monitoring URL: https://{state['outputs']['monitoring_domain']['value']}/{state['outputs']['monitoring_secret']['value']}/")
        print(f" Admin URL: https://{name}.infra.srk.bz/")
        print(f" Admin Password: {state['outputs']['minecraft_admin_password']['value']}")

    conn.close()

def get_connection_string():
    pg_connection_string = ''
    with open('./.terraform/terraform.tfstate') as reader:
        terraform_state = json.loads(reader.read())
        pg_connection_string = terraform_state['backend']['config']['conn_str']
    return pg_connection_string

if __name__ == '__main__':
    app()
