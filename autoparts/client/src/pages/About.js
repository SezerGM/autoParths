import React from "react";
import Layout from "../components/Layout/Layout";

const About = () => {
  return (
    <Layout title={"О нас - AutoParts"}>
      <div className="row contactus">
        <div className="col-md-6">
          <img
            src="/images/about.jpeg"
            alt="contactus"
            style={{ width: "100%" }}
          />
        </div>
        <div className="col-md-4">
          <p className="text-justify mt-2">
            В современном мире онлайн-покупки стали неотъемлемой частью нашей
            повседневной жизни, и мы стремимся предоставить удобную и
            пользовательскую платформу для приобретения автозапчастей.
          </p>
          <p>
            Наша главная цель — предложить вам эффективный и удобный способ
            покупки автозапчастей, гарантируя при этом высокое качество товаров
            по разумным ценам в рублях (₽).
          </p>
        </div>
      </div>
    </Layout>
  );
};

export default About;