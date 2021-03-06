

select distinct * 
from
(
		select --ig.name_l as item_group_name,
			   i.item_code,
			   i.name_l as item_name,
			   --i.item_id,
			   po_date = (Select top 1 created_on_date 
							from swe_purchase_order spo inner join swe_purchase_order_detail spod on spo.purchase_order_id = spod.purchase_order_id
														inner join swe_vendor_item svi on svi.vendor_item_id = spod.vendor_item_id
							where cast(convert(varchar(10),created_on_date,101)as smalldatetime) <= cast(convert(varchar(10),'12/31/2018',101)as smalldatetime)
							and svi.item_id = isd.item_id
							order by created_on_date desc),
			   --v.vendor_code,
			   vendor_name = (SELECT name_l from organisation WHERE organisation_id = v.organisation_id),
			   iiu.uom_rcd,
			   qty_on_hand = (Select top 1 qty_on_hand
							from inventory_summary_day _spo 
							where _spo.item_id = isd.item_id
							order by date_time desc),
			   qty_on_hand_cost = (Select top 1 qty_on_hand_cost
							from inventory_summary_day _spo 
							where _spo.item_id = isd.item_id
							order by date_time desc)
			   /*average_unit_cost = (Select top 1 average_unit_cost
							from inventory_summary_day _spo 
							where _spo.item_id = isd.item_id
							order by date_time desc)*/


		from inventory_summary_day isd inner join item i on i.item_id = isd.item_id
									   inner join item_group ig on i.item_group_id = ig.item_group_id
									   inner join store s on s.store_id = isd.store_id
									   inner join inventory_item_uom iiu on isd.item_id = iiu.item_id
									   LEFT outer join swe_vendor_item svi on i.item_id = svi.item_id
									   LEFT outer join vendor v on svi.vendor_id = v.vendor_id	

		where i.active_flag = 1
			  --and s.store_id = '08CD273C-19CE-11DA-A79E-001143B8816C'          --Central Warehouse
			  and s.store_id = '08CD273F-19CE-11DA-A79E-001143B8816C'      --POS
			  and ig.item_group_id = 'F4678B58-5C74-4B6E-A527-83C5BF98032C'    --OR Supplies - Exclusive
			  --and i.item_code = '588-0018'
) as temp
where po_date is not null
	  and qty_on_hand > 0
order by temp.item_name asc




/*
select * 
from (
	select item_code,
		   name_l,
		   --item_id,
		   po_date = (Select top 1 created_on_date 
						from swe_purchase_order spo inner join swe_purchase_order_detail spod on spo.purchase_order_id = spod.purchase_order_id
													inner join swe_vendor_item svi on svi.vendor_item_id = spod.vendor_item_id
						where cast(convert(varchar(10),created_on_date,101)as smalldatetime) <= cast(convert(varchar(10),'12/31/2018',101)as smalldatetime)
						and svi.item_id = i.item_id
						AND SPO.swe_purchase_site_id = '2198E881-0E1D-11DA-A79E-001143B8816C'  --For Pharmacy Purchasing
						--AND SPO.swe_purchase_site_id = '31488C46-FDB0-11D9-A79B-001143B8816C'   --For Central Purchasing
						order by created_on_date desc) 

	from item i 
	where i.active_flag = 1
) as temp
where po_date is not null
order by item_code asc
*/
