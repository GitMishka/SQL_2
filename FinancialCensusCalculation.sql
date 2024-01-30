select top 10 * from ServiceInstance si
	join service s on s.serviceid = si.ServiceID
where ServiceClassID = 1 and ServiceInstanceActiveFlag = 1 and ServiceInstanceFromDate <= ISNULL(ServiceInstanceToDate,ServiceInstanceFromDate)