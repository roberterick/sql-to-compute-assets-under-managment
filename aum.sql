declare @edate date = '2022-01-31';
declare @minpostedflag integer=2;
--fix gip computation

declare @table Table (
x varchar(1)
,fund varchar(4)
,fund_name varchar(255)
,account varchar(10)
,account_name varchar(255)
,fin2 varchar(5)
,amount decimal(25,2)

,inv_and_cash decimal(25,2)
,pledges decimal(25,2)
,real_estate decimal(25,2)
,other decimal(25,2)

,vip1 decimal(25,2)
,vip2 decimal(25,2)
,vip3 decimal(25,2)
,pending_fund decimal(25,2)
,t3 decimal(25,2)

,gip1_uof decimal(25,2)
,gip2_uof decimal(25,2)
,gip3_uof decimal(25,2)

,gip1_so decimal(25,2)
,gip2_so decimal(25,2)
,gip3_so decimal(25,2)

,itp1 decimal(25,2)
,itp2 decimal(25,2)
,itp3 decimal(25,2)

,trusts decimal(25,2)
,other2 decimal(25,2)
);

insert into @table
select
''
,fund.fund_number
,fund.fund_description
,acct.account_number
,acct.account_description
,acct.fin2_2017_code
,sum(trx.amount)

,0,0,0,0
,0,0,0,0,0,0,0,0,0,0,0,0,0
,0,0,0
from acctetl.dbo.uo_gl_transaction trx
join acctetl.dbo.uo_fund fund on fund.fund_id=trx.fund_id
join acctetl.dbo.uo_account acct on acct.account_id=trx.account_id
join acctetl.dbo.uo_batch batch on batch.batch_id=trx.batch_id
where
trx.post_date<=@edate
and (left(fin2_2017_code,1) in ('1') or fin2_2017_code in ('995'))
and trx.post_status_code>=@minpostedflag
group by
fund.fund_number
,fund.fund_description
,acct.account_number
,acct.account_description
,acct.fin2_2017_code
having sum(trx.amount)<>0
;

update @table set inv_and_cash=amount where fin2 in ('100','110','120','130','140');
update @table set pledges=amount where fin2 in ('150');
update @table set real_estate=amount where fin2 in ('160','170');
update @table set other=amount where fin2 in ('180','190');
--

update @table set vip1=amount where fin2 in ('995') and fund in ('2500');
update @table set vip2=amount where fin2 in ('100','110','120','130','140') and fund in ('2500');
update @table set vip3=amount where fin2 in ('995') and fund not in ('2500');

update @table set pending_fund=amount where fin2 in ('100','110','120','130','140') and fund in ('8430');
update @table set t3=amount where fin2 in ('100','110','120','130','140') and fund in ('8011');

update @table set gip1_uof=amount where fin2 in ('100','110','120','130','140') and left(account,5) in ('11100') and fund in ('0001');
update @table set gip2_uof=amount where fin2 in ('100','110','120','130','140') and left(account,5) not in ('11100','11199','11133') and fund in ('0001');
update @table set gip3_uof=amount where fin2 in ('100','110','120','130','140') and left(account,5) in ('11100') and fund not in ('0001');

update @table set gip1_so=amount where fin2 in ('100','110','120','130','140') and left(account,5) in ('11199') and fund in ('0001');
update @table set gip2_so=amount where fin2 in ('100','110','120','130','140') and left(account,5) not in ('11199') and left(account,5) in ('11133') and fund in ('0001');
update @table set gip3_so=amount where fin2 in ('100','110','120','130','140') and left(account,5) in ('11199') and fund not in ('0001');

update @table set itp1=amount where fin2 in ('100','110','120','130','140') and left(account,5) in ('11150') and fund in ('0003');
update @table set itp2=amount where fin2 in ('100','110','120','130','140') and not left(account,5) in ('11150') and fund in ('0003');
update @table set itp3=amount where fin2 in ('100','110','120','130','140') and  left(account,5) in ('11150') and fund not in ('0003');

update @table set trusts=amount where fin2 in ('100','110','120','130','140') and left(account,3) in ('145');
--
update @table set other2=amount where fin2 in ('100','110','120','130','140') and fund not in ('0001','0003','2500','8011','8430') and not left(account,5) in ('11100','11150','11199') and not left(account,3) in ('145');

select *
from @table
order by 6,2,3;