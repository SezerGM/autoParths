/* eslint-disable jsx-a11y/alt-text */
import React from "react";
import Layout from "./../components/Layout/Layout";
import { BiMailSend, BiPhoneCall, BiSupport } from "react-icons/bi";
// eslint-disable-next-line no-unused-vars

const Contact = () => {
  return (
    <Layout title={"Свяжитесь с нами"}>
      <div className="row contactus ">
        <div className="col-md-6 ">
          <img
            src="/images/contactus.jpeg"
            alt="contactus"
            style={{ width: "100%" }}
          />
        </div>
        <div className="col-md-4">
          <h1 className="bg-dark p-2 text-white text-center">СВЯЖИТЕСЬ С НАМИ</h1>
          <p className="text-justify mt-2">
            СВЯЖИТЕСЬ С НАМИ - мы доступны 24/7
          </p>
          <p className="mt-3">
            <BiMailSend /> : www.help@autoparts.com
          </p>
          <p className="mt-3">
            <BiPhoneCall /> : 012-3456789
          </p>
          <p className="mt-3">
            <BiSupport /> : 1800-0000-0000 (бесплатно)
          </p>
        </div>
      </div>
    </Layout>
  );
};

export default Contact;
