import React from 'react';
import ReactDOM from 'react-dom/client';
import './reset.css';
import './global.css';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';

// if you want to use recoil and react-router-dom, you can wrap the App component
// import { BrowserRouter, Route, Routes } from "react-router-dom";
// import { RecoilRoot } from 'recoil';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  // <React.StrictMode>
    <App />
  // </React.StrictMode>

  // if you want to use Recoil and react-router-dom, you can wrap the App component
  // <RecoilRoot>
  //   <BrowserRouter>
  //     <Routes>
  //       <Route path="/*" element={<App />} />
  //     </Routes>
  //   </BrowserRouter>
  // </RecoilRoot>

);

reportWebVitals();