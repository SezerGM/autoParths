import React, { useState, useEffect } from "react";
import Layout from "./../components/Layout/Layout";
import axios from "axios";
import { useParams, useNavigate } from "react-router-dom";
import "../styles/ProductDetailsStyles.css";

const ProductDetails = () => {
  const params = useParams();
  const navigate = useNavigate();
  const [product, setProduct] = useState({});
  const [relatedProducts, setRelatedProducts] = useState([]);

  // Начальные данные
  useEffect(() => {
    if (params?.slug) getProduct();
  }, [params?.slug]);

  // Получить продукт
  const getProduct = async () => {
    try {
      const { data } = await axios.get(
        `${process.env.REACT_APP_API}/api/v1/product/get-product/${params.slug}`
      );
      setProduct(data?.product);
      getSimilarProduct(data?.product._id, data?.product.category._id);
    } catch (error) {
      console.log(error);
    }
  };

  // Получить похожие продукты
  const getSimilarProduct = async (pid, cid) => {
    try {
      const { data } = await axios.get(
        `${process.env.REACT_APP_API}/api/v1/product/related-product/${pid}/${cid}`
      );
      setRelatedProducts(data?.products);
    } catch (error) {
      console.log(error);
    }
  };

  return (
    <Layout>
      <div className="row container product-details">
        <div className="col-md-6">
          <img
            src={`${process.env.REACT_APP_API}/api/v1/product/product-photo/${product._id}`}
            className="card-img-top"
            alt={product.name}
            height="300"
            width={"350px"}
          />
        </div>
        <div className="col-md-6 product-details-info">
          <h1 className="text-center">Детали продукта</h1>
          <hr />
          <h6>Название: {product.name}</h6>
          <h6>Описание: {product.description}</h6>
          <h6>
            Цена:
            {product?.price?.toLocaleString("en-IN", {
              style: "currency",
              currency: "INR",
            })}
          </h6>
          <h6>Категория: {product?.category?.name}</h6>
          <button className="btn btn-secondary ms-1">ДОБАВИТЬ В КОРЗИНУ</button>
        </div>
      </div>
      <hr />
      <div className="row container similar-products">
        <h4>Похожие продукты ➡️</h4>
        {relatedProducts.length < 1 && (
          <p className="text-center">Похожие продукты не найдены</p>
        )}
        <div className="d-flex flex-wrap">
          {relatedProducts?.map((p) => (
            <div className="card m-2" key={p._id}>
              <img
                src={`${process.env.REACT_APP_API}/api/v1/product/product-photo/${p._id}`}
                className="card-img-top"
                alt={p.name}
              />
              <div className="card-body">
                <div className="card-name-price">
                  <h5 className="card-title">{p.name}</h5>
                  <h5 className="card-title card-price">
                    {p.price.toLocaleString("en-IN", {
                      style: "currency",
                      currency: "INR",
                    })}
                  </h5>
                </div>
                <p className="card-text">
                  {p.description.substring(0, 60)}...
                </p>
                <div className="card-name-price">
                  <button
                    className="btn btn-info ms-1"
                    onClick={() => navigate(`/product/${p.slug}`)}
                  >
                    Подробнее
                  </button>
                  {/* 
                  <button
                    className="btn btn-dark ms-1"
                    onClick={() => {
                      setCart([...cart, p]);
                      localStorage.setItem(
                        "cart",
                        JSON.stringify([...cart, p])
                      );
                      toast.success("Товар добавлен в корзину");
                    }}
                  >
                    ДОБАВИТЬ В КОРЗИНУ
                  </button> 
                  */}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </Layout>
  );
};

export default ProductDetails;
