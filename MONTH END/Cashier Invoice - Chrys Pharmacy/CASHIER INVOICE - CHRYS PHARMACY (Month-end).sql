SELECT temp.hn, 
       temp.patient_name, 
       temp.visit_type_rcd, 
       temp.invoice_number, 
       temp.invoice_amount, 
       temp.gross_amount + temp.coveredby_co_payor as gross_amount, 
	   case WHEN (temp.gross_amount + temp.coveredby_co_payor) > 0 then CAST((temp.gross_amount + temp.coveredby_co_payor) / 1.12 as NUMERIC(12,2)) else 0 end as vatable_sales, 
       case when (temp.gross_amount + temp.coveredby_co_payor) > 0 THEN CAST((temp.gross_amount + temp.coveredby_co_payor) - CAST((temp.gross_amount + temp.coveredby_co_payor) / 1.12 as NUMERIC(12,2)) as NUMERIC(12,2)) else 0 end as vat,  
	   temp.coveredby_co_payor, 
	   case when (ISNULL(temp.deposit,0) < 1  and temp.deposit > 0) then 0   
			when ISNULL(temp.deposit,0) <= 0 then 0   
			when ISNULL(temp.deposit,0) > 1 THEN temp.deposit end as deposit,  
	   temp.deposit as orig_deposit,   
	   sum(temp.discount_amount) as discount,  
	   temp.transaction_date_time,
	   CONVERT(VARCHAR(20), temp.transaction_date_time,101) AS [Transaction Date],
		FORMAT(temp.transaction_date_time,'hh:mm tt') AS [Transaction Time]
from 
( 
    SELECT phu.visible_patient_id as hn, 
           pfn.display_name_l as patient_name, 
           invoice_number, 
           ci.invoice_customer_id, 
           invoice_amount, 
           pfn.display_name_l as patientname, 
           ISNULL((SELECT SUM(deposit_amount) - 
                           SUM(ABS(used_amount)) as deposit 
                    from patient_deposit_balance pdb  
                    where  customer_id = ci.invoice_customer_id),0) as deposit, 
         isnull( (SELECT SUM(temp.co_payor_amt) 
            from 
            ( 
                SELECT DISTINCT a.transaction_text, 
                       a.gross_amount - a.discount_amount as co_payor_amt 
                from ar_invoice a inner JOIN ar_invoice_detail b on a.ar_invoice_id = b.ar_invoice_id 
                            inner JOIN charge_detail c on b.charge_detail_id = c.charge_detail_id 
                            inner join patient_visit d on c.patient_visit_id = d.patient_visit_id 
                            inner JOIN policy e on a.policy_id = e.policy_id 
                where c.patient_visit_id = ar.patient_visit_id 
                    and e.policy_type_rcd = 'INS' 
                    and a.transaction_status_rcd <> 'VOI' 
            ) as temp),0) as coveredby_co_payor, 
            cid.discount_amount, 
            ar.tax_amount  as vat, 
            ar.patient_visit_id, 
            ar.gross_amount, 
            ar.visit_type_rcd,
			ar.transaction_date_time
    from cashier_invoice_view ci INNER JOIN patient_hospital_usage phu on ci.invoice_customer_id = phu.patient_id 
                                 inner JOIN person_formatted_name_iview_nl_view pfn on ci.invoice_customer_id = pfn.person_id 
                                 inner JOIN (SELECT distinct a.transaction_text, 
	                                               c.patient_visit_id, 
		                                               a.tax_amount, 
	                                               a.gross_amount, 
                                                  rtrim(a.visit_type_rcd) as visit_type_rcd ,
												  a.transaction_date_time,
												  a.transaction_status_rcd
                                            from ar_invoice a inner JOIN ar_invoice_detail b on a.ar_invoice_id = b.ar_invoice_id 
					                                              inner JOIN charge_detail c on b.charge_detail_id = c.charge_detail_id 
				                                              inner join patient_visit d on c.patient_visit_id = d.patient_visit_id) ar on ci.invoice_number = ar.transaction_text 
                                 INNER JOIN cashier_invoice_detail_view cid on ci.invoice_id = cid.invoice_id 
    where MONTH(ar.transaction_date_time) = @Month
		and YEAR(ar.transaction_date_time) = @Year
		and ar.transaction_status_rcd <> 'VOI'
		and ar.visit_type_rcd = 'V32   ' --chrys pharmacy 
) as temp 
group by temp.hn, 
         temp.patient_name, 
         temp.visit_type_rcd, 
         temp.invoice_number, 
		 temp.transaction_date_time,
         temp.gross_amount, 
         temp.invoice_amount, 
         temp.coveredby_co_payor, 
         temp.vat, 
         temp.deposit
order by temp.transaction_date_time --temp.invoice_number
