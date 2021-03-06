
DECLARE @dateFrom datetime
DECLARE @dateTo datetime

SET @dateFrom = '10/01/2019 00:00:00.000'		
SET @dateTo = '12/31/2019 23:59:59.998'

select *
from
(
	SELECT ppdh.employee_nr as [Employee NR],
	  cv.caregiver_name as [Caregiver],
	  ppdh.hospital_number as [Hospital Number],
	  ppdh.pname as [Patient Name],
	  i.item_code as [Item Code],
	  ppdh.item_desc as [Item Desc],
	  ppdh.charge_amount as [Charge Amount],
	  ppdh.tax_rate as [Tax Rate],
	  ppdh.vat_rate as [Vat Rate],
	  ppdh.discount_amount as [Discount Amount],
	  ppdh.discount_amount_scd as [Discount Amount SCD],
	  ppdh.discount_amount_oth as [Discount Amount OTH],
	  ppdh.merchant_discount as [Merchant Discount],
	  ppdh.adjustment_amount [Adjustment Amount],
	  ppdh.net_amount as [Net Amount],
	  ppdh.vat_amount as [Vat Amount],
	  ppdh.tax_amount as [Tax Amount],
	  ppdh.credited_amount as [Credited Amount],
	  ppdh.commission_rate as [Commission Rate],
	  ppdh.charge_date as [Charge Date],
	  s.payout_date_start as [Payout Date],
	  ppdh.gross_amount as [Gross Amount],
	  ppdh.invoice_number as [Invoice Number],
	  ar.transaction_date_time as [Invoice Date],
	  gac.gl_acct_code_code as [GL Account Code],
	  gac.name_l as [GL Account Name],
	  s.credit_date_start as [Period Date],
	  ppdh.policy_group as [Policy Group]
	  ,validated_datetime = (Select top 1 updated_datetime from dbo.charge_audit_trail where charge_id = PPDH.charge_id order by updated_datetime desc)

from payment_period_details_history ppdh inner JOIN payment_period pp on ppdh.period_id = pp.period_id
										 inner JOIN schedule s on pp.schedule_id = s.schedule_id
										 inner JOIN caregiver_view cv on ppdh.employee_nr = cv.employee_nr
										 inner join ar_invoice_details ard on ppdh.ar_invoice_detail_id = ard.ar_invoice_detail_id
										 INNER join dbo.ar_invoices ar on ard.ar_invoice_id = ar.ar_invoice_id
										 inner join gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
										 inner join dbo.items i on ard.item_id = i.item_id

where CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dateFrom,101) as SMALLDATETIME)
     and CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dateTo,101) as SMALLDATETIME)
     and ppdh.policy_group <> 'Manual Entry'
UNION all
	SELECT ppdh.employee_nr as [Employee NR],
	  cv.caregiver_name as [Caregiver],
	  ppdh.hospital_number as [Hospital Number],
	  ppdh.pname as [Patient Name],
	  i.item_code as [Item Code],
	  ppdh.item_desc as [Item Desc],
	  ppdh.charge_amount as [Charge Amount],
	  ppdh.tax_rate as [Tax Rate],
	  ppdh.vat_rate as [Vat Rate],
	  ppdh.discount_amount as [Discount Amount],
	  ppdh.discount_amount_scd as [Discount Amount SCD],
	  ppdh.discount_amount_oth as [Discount Amount OTH],
	  ppdh.merchant_discount as [Merchant Discount],
	  ppdh.adjustment_amount [Adjustment Amount],
	  ppdh.net_amount as [Net Amount],
	  ppdh.vat_amount as [Vat Amount],
	  ppdh.tax_amount as [Tax Amount],
	  ppdh.credited_amount as [Credited Amount],
	  ppdh.commission_rate as [Commission Rate],
	  ppdh.charge_date as [Charge Date],
	  s.payout_date_start as [Payout Date],
	  ppdh.gross_amount as [Gross Amount],
	  ppdh.invoice_number as [Invoice Number],
	  ar.transaction_date_time as [Invoice Date],
	  gac.gl_acct_code_code as [GL Account Code],
	  gac.name_l as [GL Account Name],
	  s.credit_date_start as [Period Date],
	  ppdh.policy_group as [Policy Group]
	  ,validated_datetime = (Select top 1 updated_datetime from dbo.charge_audit_trail where charge_id = PPDH.charge_id order by updated_datetime desc)


from payment_period_details_history ppdh inner JOIN payment_period pp on ppdh.period_id = pp.period_id
										 inner JOIN schedule s on pp.schedule_id = s.schedule_id
										 inner JOIN caregiver_view cv on ppdh.employee_nr = cv.employee_nr
										 inner join manual_entries me on ppdh.manual_entry_id = me.manual_entry_id
										 LEFT outer join gl_acct_code gac on me.gl_account_id = gac.gl_acct_code_id
										 left join ar_invoice_details ard on ppdh.ar_invoice_detail_id = ard.ar_invoice_detail_id
										 left join dbo.ar_invoices ar on ard.ar_invoice_id = ar.ar_invoice_id
										 left join dbo.items i on ard.item_id = i.item_id

where CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dateFrom,101) as SMALLDATETIME)
     and CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dateTo,101) as SMALLDATETIME)
     and ppdh.policy_group = 'Manual Entry'
) as temp
--where temp.[Employee NR] = '2904'
order by temp.[Period Date],temp.Caregiver,temp.[Charge Date]





	/*
	SELECT ppdh.employee_nr as [Employee NR],
	  cv.caregiver_name as [Caregiver],
	  ppdh.hospital_number as [Hospital Number],
	  ppdh.pname as [Patient Name],
	  ppdh.item_desc as [Item Desc],
	  ppdh.charge_amount as [Charge Amount],
	  ppdh.tax_rate as [Tax Rate],
	  ppdh.vat_rate as [Vat Rate],
	  ppdh.discount_amount as [Discount Amount],
	  ppdh.discount_amount_scd as [Discount Amount SCD],
	  ppdh.discount_amount_oth as [Discount Amount OTH],
	  ppdh.merchant_discount as [Merchant Discount],
	  ppdh.adjustment_amount [Adjustment Amount],
	  ppdh.net_amount as [Net Amount],
	  ppdh.vat_amount as [Vat Amount],
	  ppdh.tax_amount as [Tax Amount],
	  ppdh.credited_amount as [Credited Amount],
	  ppdh.commission_rate as [Commission Rate],
	  ppdh.charge_date as [Charge Date],
	  s.payout_date_start as [Payout Date],
	  ppdh.gross_amount,
	  ppdh.invoice_number
from payment_period_details_history ppdh inner JOIN payment_period pp on ppdh.period_id = pp.period_id
										 inner JOIN schedule s on pp.schedule_id = s.schedule_id
										 inner JOIN caregiver_view cv on ppdh.employee_nr = cv.employee_nr
where CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@dateFrom,101) as SMALLDATETIME)
     and CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@dateTo,101) as SMALLDATETIME)
order by s.credit_date_start, cv.caregiver_name,ppdh.charge_date
*/
