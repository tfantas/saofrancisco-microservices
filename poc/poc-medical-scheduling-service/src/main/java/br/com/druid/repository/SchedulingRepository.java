package br.com.druid.repository;

import java.util.List;

import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RestResource;

import br.com.druid.healthcare.domain.Scheduling;

@RestResource(path="scheduling", rel="scheduling")
public interface SchedulingRepository extends CrudRepository<Scheduling,Long>{
	List<Scheduling>findByDoctorIdentifier(@Param("doctorIdentifier") String doctorIdentifier);
}
