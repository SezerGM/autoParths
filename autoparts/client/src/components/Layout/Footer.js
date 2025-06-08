import React from "react";
import { Link } from "react-router-dom";

const Footer = () => {
  return (
    <div className="footer">
      <h4 className="text-center">Все права защищены &copy; AutoParts</h4>
      <p className="text-center mt-3">
        <Link to="/about">О нас</Link>|<Link to="/contact">Контакты</Link>|
        <Link to="/policy">Политика конфиденциальности</Link>
      </p>
    </div>
  );
};

export default Footer;
