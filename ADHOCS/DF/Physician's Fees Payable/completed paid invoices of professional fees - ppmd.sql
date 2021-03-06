
SELECT 
      ppdh.employee_nr as [Employee NR],
	  cv.caregiver_name as [Caregiver],
	  --ppdh.hospital_number as [Hospital Number],
	  --ppdh.pname as [Patient Name],
	  ar.transaction_date_time as [Transaction Date],
	  ppdh.invoice_number as [Transaction No],
	  ppdh.gross_amount as [Gross Amount],
	  cd.item_code as [Item Code],
	  ppdh.item_desc as [Item Description],
	  ppdh.credited_amount as [Credited Amount],
	  gac.gl_acct_code_code as [GL Account Code],
	  gac.name_l as [GL Account Name]

from payment_period_details_history ppdh inner JOIN payment_period pp on ppdh.period_id = pp.period_id
										 inner JOIN schedule s on pp.schedule_id = s.schedule_id
										 inner JOIN caregiver_view cv on ppdh.employee_nr = cv.employee_nr
										 inner join ar_invoice_details ard on ppdh.ar_invoice_detail_id = ard.ar_invoice_detail_id
										 inner join ar_invoices ar on ard.ar_invoice_id = ar.ar_invoice_id
										 inner join gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
										 inner join charge_details_vw cd on ppdh.charge_id = cd.charge_id

where CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2019',101) as SMALLDATETIME)
     and CAST(CONVERT(VARCHAR(10),s.credit_date_start,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'09/30/2019',101) as SMALLDATETIME)
     and ppdh.policy_group <> 'Manual Entry'
	 and gac.gl_acct_code_code IN ('2152100', '2152250')

order by ar.transaction_date_time