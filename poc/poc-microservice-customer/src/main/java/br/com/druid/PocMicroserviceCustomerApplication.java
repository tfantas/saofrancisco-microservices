package br.com.druid;

import java.util.HashSet;
import java.util.Set;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

import br.com.druid.domain.Customer;
import br.com.druid.repository.CustomerRepository;

@SpringBootApplication
@EnableDiscoveryClient
public class PocMicroserviceCustomerApplication {

	@Autowired 
	CustomerRepository customerRepository;
	
	public static void main(String[] args) {
		SpringApplication.run(PocMicroserviceCustomerApplication.class, args);
	}

	@PostConstruct
	public void init() {

		Set<Customer> set = new HashSet<>();
		set.add(new Customer("733999000001" , "TesteName1", "1234567890", 48));
		set.add(new Customer("733999000002" , "TesteName2", "1234567891", 37));
		set.add(new Customer("733999000003" , "TesteName3", "1234567892", 21));

		customerRepository.save(set);
	}
}
