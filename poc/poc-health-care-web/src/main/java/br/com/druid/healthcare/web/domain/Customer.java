package br.com.druid.healthcare.web.domain;

import java.io.Serializable;

import com.fasterxml.jackson.annotation.JsonRootName;

@JsonRootName("customer")
public class Customer implements Serializable {
	
	private static final long serialVersionUID = -8796773624363904684L;

	Long id;
	String cardNumber;
	String name;
	String cpf;
	Integer age;
	
	public Customer() {
		super();
	}	
	public Customer(String cardNumber, String name, String cpf, Integer age) {
		this();
		this.cardNumber = cardNumber;
		this.age = age;
		this.name = name;
		this.cpf = cpf;
	}
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getCpf() {
		return cpf;
	}
	public void setCpf(String cpf) {
		this.cpf = cpf;
	}
	public Integer getAge() {
		return age;
	}
	public void setAge(Integer age) {
		this.age = age;
	}
	public String getCardNumber() {
		return cardNumber;
	}
	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

}
