import React from "react";
import Layout from "./../components/Layout/Layout";
import { useSearch } from "../context/search";

const Search = () => {
  const [values, setValues] = useSearch();
  return (
    <Layout title={"Результаты поиска"}>
      <div className="container">
        <div className="text-center">
          <h1>Результаты поиска</h1>
          <h6>
            {values?.results.length < 1
              ? "Товары не найдены"
              : `Найдено ${values?.results.length}`}
          </h6>
          <div className="d-flex flex-wrap mt-4">
            {values?.results.map((p) => (
              <div className="card m-2" style={{ width: "18rem" }} key={p._id}>
                <img
                  src={`${process.env.REACT_APP_API}/api/v1/product/product-photo/${p._id}`}
                  className="card-img-top"
                  alt={p.name}
                />
                <div className="card-body">
                  <h5 className="card-title">{p.name}</h5>
                  <p className="card-text">
                    {p.description.substring(0, 30)}...
                  </p>
                  <p className="card-text">₽ {p.price}</p>
                  <button className="btn btn-primary ms-1">Подробнее</button>
                  <button className="btn btn-secondary ms-1">ДОБАВИТЬ В КОРЗИНУ</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default Search;
