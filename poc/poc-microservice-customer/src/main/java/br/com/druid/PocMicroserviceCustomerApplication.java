package br.com.druid;

import java.util.HashSet;
import java.util.Set;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import br.com.druid.domain.Customer;
import br.com.druid.repository.CustomerRepository;

@SpringBootApplication
public class PocMicroserviceCustomerApplication {

	@Autowired 
	CustomerRepository customerRepository;
	
	public static void main(String[] args) {
		SpringApplication.run(PocMicroserviceCustomerApplication.class, args);
	}

	@PostConstruct
	public void init() {

		Set<Customer> set = new HashSet<>();
		set.add(new Customer("TesteName1", "1234567890", 48));
		set.add(new Customer("TesteName2", "1234567891", 37));
		set.add(new Customer("TesteName3", "1234567892", 21));

		customerRepository.save(set);
	}
}
