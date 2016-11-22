package br.com.druid.healthcare.domain;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
public class Scheduling {
	
	@Id
	@GeneratedValue
	Long id;
	String customerCardNumber;
	String doctorIdentifier;
	Date   scheduleDate;
	
	
	public Scheduling( String customerCardNumber, String doctorIdentifier, Date scheduleDate) {
		super();
		this.customerCardNumber = customerCardNumber;
		this.doctorIdentifier = doctorIdentifier;
		this.scheduleDate = scheduleDate;
	}
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getCustomerCardNumber() {
		return customerCardNumber;
	}
	public void setCustomerCardNumber(String customerCardNumber) {
		this.customerCardNumber = customerCardNumber;
	}
	public String getDoctorIdentifier() {
		return doctorIdentifier;
	}
	public void setDoctorIdentifier(String doctorIdentifier) {
		this.doctorIdentifier = doctorIdentifier;
	}
	public Date getScheduleDate() {
		return scheduleDate;
	}
	public void setScheduleDate(Date scheduleDate) {
		this.scheduleDate = scheduleDate;
	}

}
