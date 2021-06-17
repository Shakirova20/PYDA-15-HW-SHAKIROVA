--«адача 5
select f.actual_departure, f.departure_airport, f.flight_id,
	s2.all_seats - bp.prodano as svobodno,  --считаем сколько мест осталось свободно
	bp.prodano as prodano,
	s2.all_seats as vsego,
	round((s2.all_seats - bp.prodano)/s2.all_seats*100, 2) as procent,  --вычисл€ем процент свободных мест
	sum(bp.prodano) over (partition by f.actual_departure::date, f.departure_airport order by f.actual_departure) as Cumulative_Total --считаем 
	--нарастающим итогом сумму проданных мест
from flights f  --таблица с необходимымыи данными
left join (select bp.flight_id,
	 		count(bp.seat_no) :: numeric as prodano
	 		from boarding_passes bp
	 		group by bp.flight_id) as bp
	 on f.flight_id  = bp.flight_id  --считаем строки, сколько выдано посадочных талонов
left join (select s2.aircraft_code, count(s2.seat_no)::numeric as all_seats
       		from seats s2
     		group by s2.aircraft_code) as s2
	 on f.aircraft_code  = s2.aircraft_code  --считаем строки, сколько всего мест на каждом типе самолета
where actual_departure is not null and bp.prodano is not null --отсекаем некорректные данные


--«адача 6
select f2.aircraft_code, 
		count(f2.aircraft_code)::numeric as c, --считаем сколько рейсов всего
		round (count(f2.aircraft_code)::numeric / (select count(f.flight_id)::numeric
		from flights f)*100, 2)
from flights f2
group by f2.aircraft_code  --так считаем сколько рейсов делает каждый тип самолета


--«адача7
WITH eco as (select flight_id, fare_conditions, max(amount) as cost_eco
		from ticket_flights
		where fare_conditions = 'Economy'
		group by flight_id, fare_conditions ),
bus AS (select tf.flight_id, tf.fare_conditions, min(tf.amount) as cost_bus
		from ticket_flights tf
		where tf.fare_conditions = 'Business'
		group by tf.flight_id, tf.fare_conditions)
select f2.flight_id, cost_eco, cost_bus, eco.fare_conditions, ad.airport_code, ad.city 
from eco join bus on eco.flight_id = bus.flight_id	
	join flights f2 on eco.flight_id = f2.flight_id 
	join airports_data ad on f2.arrival_airport = ad.airport_code
where cost_eco > cost_bus



