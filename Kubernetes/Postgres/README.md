# POSTGRES

Start
```
% ./manage-postgres.sh 
Usage: ./manage-postgres.sh {deploy|start|stop|min|delete}
  deploy: Creates or updates all resources defined in postgres.yaml.
  start:  Scales the deployment to 3 replicas.
  stop:   Scales the deployment to 0 replicas.
  min:    Scales the deployment to 1 replica.
  delete: Deletes all resources defined in postgres.yaml.
```

Test
```
> psql -h batman.local -p 5432 -U postgres -d postgres
Password for user postgres: 
psql (17.6)
Type "help" for help.

postgres=# \du
                             List of roles
 Role name |                         Attributes                         
-----------+------------------------------------------------------------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS

postgres=# 
```
