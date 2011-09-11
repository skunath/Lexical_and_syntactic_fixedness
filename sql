get complexities:
update disco_data_computations d set d.complexity_4 = (select avg(e.complexity_impact) from disco_occurrences e where d.disco_data_id = e.disco_data_id and e.distance = 4)



