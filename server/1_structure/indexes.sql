create index err_descr_idx on sl_errors(err_description);
create index standard_notif_idx on standard_notifications(cod_notif);
create index idx_req_type_of on requests(type_of_req);
create index idx_req_status on requests(Status);
create index idx_req_acc_id on requests(Acc_id);
create index idx_req_total_days on requests(total_no_of_days);
create index on activities(act_code);
create index idx_days_req_code on days_per_year(req_code);
create index idx_req_type_code on request_types(req_code);                                                                                                            