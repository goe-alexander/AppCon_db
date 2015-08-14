select * from app_users

--## Constraints added at second analysis
alter table x
add constraint <name>
FOREIGN KEY (x.column)
REFERENCES (tab.PK);
