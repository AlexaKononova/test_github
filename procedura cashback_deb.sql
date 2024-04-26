create or replace procedure cashback_deb is
begin
  for rec in (select sum (pro.sum_operation) as l_sum, pro.accountid_cred as l_accountid
                from cards c
                join cashback cb  
                  on cb.cardnomer=c.cardnomer 
                 and (add_months(trunc(sysdate),-1) - cb.date_in) >= 0
                 and cb.date_out is null 
                join pro
                  on pro.accountid_cred = c.accountid
                 and (pro.date_operation - add_months(trunc(sysdate),-1))>= 0
                group by pro.accountid_cred
               having count(pro.accountid_cred) >= 3)
  loop
    begin
        insert into pro  (date_operation, 
                          accountid_deb, 
                          accountid_cred, 
                          sum_operation, 
                          doc_num, 
                          doc_date,
                          comment_operation)
        values
        (trunc(sysdate),
         rec.l_accountid,
         0,
         0.01*rec.l_sum,
         '',
         '',
         'Начисление кэшбека');
    exception
      when others then
        dbms_output.put_line ('ошибка операции '|| sqlerrm);
    end;
  end loop;

end;
