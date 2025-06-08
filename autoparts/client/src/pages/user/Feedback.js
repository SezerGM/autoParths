import Layout from "../../components/Layout/Layout";
import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import toast from "react-hot-toast";

const Feedback = () => {
  const [comment, setComment] = useState("");
  const [request, setRequest] = useState("");
  const navigate = useNavigate();

  // Функция обработки формы
  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await axios.post(
        `${process.env.REACT_APP_API}/api/v1/auth/feedback`,
        { comment, request }
      );
      if (res && res.data.success) {
        toast.success(res.data && res.data.message);
        navigate("/");
      } else {
        toast.error(res.data.message);
      }
    } catch (error) {
      console.log(error);
      toast.error("Что-то пошло не так");
    }
  };

  return (
    <Layout title="Обратная связь - AutoParts">
      <div className="form-container" style={{ minHeight: "90vh" }}>
        <form onSubmit={handleSubmit}>
          <h4 className="title">ОСТАВЬТЕ ОТЗЫВ / ЗАПРОС НА НОВЫЙ КОМПОНЕНТ</h4>
          <div className="mb-3">
            <input
              type="text"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              className="form-control"
              id="exampleInputEmail"
              placeholder="Введите ваш опыт использования сайта"
            />
          </div>
          <div className="mb-3">
            <input
              type="text"
              value={request}
              onChange={(e) => setRequest(e.target.value)}
              className="form-control"
              id="exampleInputPassword1"
              placeholder="Есть ли у вас запрос на новый компонент?"
            />
          </div>

          <button type="submit" className="btn btn-primary">
            ОТПРАВИТЬ
          </button>
        </form>
      </div>
    </Layout>
  );
};

export default Feedback;
