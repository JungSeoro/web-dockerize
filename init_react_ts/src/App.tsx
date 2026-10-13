import styles from './App.module.css';

const App: React.FC = () => {
  return (
    <div className={styles['App']}>
      <header className={styles['header']}></header>
      <div className={styles['body']}>
        <span>TSR Project</span>
      </div>
    </div>
  );
};

export default App;