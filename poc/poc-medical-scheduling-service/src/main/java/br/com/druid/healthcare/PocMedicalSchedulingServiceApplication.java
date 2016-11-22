package br.com.druid.healthcare;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

import br.com.druid.healthcare.domain.Scheduling;
import br.com.druid.repository.SchedulingRepository;

@SpringBootApplication
@EnableDiscoveryClient
public class PocMedicalSchedulingServiceApplication {

	@Autowired
	SchedulingRepository schedulingRepository;

	public static void main(String[] args) {
		SpringApplication.run(PocMedicalSchedulingServiceApplication.class, args);
	}
	
	@PostConstruct
	public void init() {
		Set<Scheduling> set = new HashSet<>();
		set.add(new Scheduling("733999000001", "MED001", new Date()));
		set.add(new Scheduling("733999000002", "MED001", new Date()));
		set.add(new Scheduling("733999000003", "MED001", new Date()));

		schedulingRepository.save(set);
	}
}
