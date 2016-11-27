package br.com.druid.healthcare.web.service;

import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import br.com.druid.healthcare.web.AccountNotFoundException;
import br.com.druid.healthcare.web.domain.Customer;

/**
 * Hide the access to the microservice inside this local service.
 * 
 * @author Paul Chapman
 */
@Service
public class WebCustomersService {

	@Autowired
	@LoadBalanced
	protected RestTemplate restTemplate;

	protected String serviceUrl;

	protected Logger logger = Logger.getLogger(WebCustomersService.class
			.getName());

	public WebCustomersService(String serviceUrl) {
		this.serviceUrl = serviceUrl.startsWith("http") ? serviceUrl
				: "http://" + serviceUrl;
	}

	/**
	 * The RestTemplate works because it uses a custom request-factory that uses
	 * Ribbon to look-up the service to use. This method simply exists to show
	 * this.
	 */
	@PostConstruct
	public void demoOnly() {
		// Can't do this in the constructor because the RestTemplate injection
		// happens afterwards.
		logger.warning("The RestTemplate request factory is "
				+ restTemplate.getRequestFactory().getClass());
	}

	public Customer findByNumber(String customersNumber) {

		logger.info("findByNumber() invoked: for " + customersNumber);
		return restTemplate.getForObject(serviceUrl + "/customers/{number}",
				Customer.class, customersNumber);
	}

	public List<Customer> byOwnerContains(String name) {
		logger.info("byOwnerContains() invoked:  for " + name);
		Customer[] customers = null;

		try {
			customers = restTemplate.getForObject(serviceUrl
					+ "/customers/search/findByName?name={name}", Customer[].class, name);
		} catch (HttpClientErrorException e) { // 404
			e.printStackTrace();
		}

		if (customers == null || customers.length == 0)
			return null;
		else
			return Arrays.asList(customers);
	}

	public Customer getByNumber(String customerNumber) {
		Customer customer = restTemplate.getForObject(serviceUrl
				+ "/customers/{number}", Customer.class, customerNumber);

		if (customer == null)
			throw new AccountNotFoundException(customerNumber);
		else
			return customer;
	}
}
