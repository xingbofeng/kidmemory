import React from 'react';
import LanguageToggle from './LanguageToggle';

const LandingHeader: React.FC = () => {
  return (
    <nav className="nav">
      <a className="brand" href="#top" aria-label="KidMemory">
        <span className="mark">
          <img src="assets/first-bear-icon.png" alt="" aria-hidden="true" />
        </span>
        <span>KidMemory</span>
      </a>
      <div className="actions">
        <LanguageToggle />
        <a
          className="github"
          href="https://github.com/xingbofeng/kidmemory"
          target="_blank"
          rel="noreferrer"
          aria-label="GitHub repository"
        >
          <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M12 .5A11.5 11.5 0 0 0 .5 12.29c0 5.21 3.36 9.63 8.03 11.2.59.11.8-.26.8-.57v-2.18c-3.27.73-3.96-1.43-3.96-1.43-.54-1.4-1.31-1.77-1.31-1.77-1.07-.75.08-.73.08-.73 1.18.09 1.8 1.25 1.8 1.25 1.05 1.85 2.76 1.32 3.43 1.01.11-.78.41-1.32.75-1.62-2.61-.31-5.35-1.34-5.35-5.96 0-1.32.46-2.39 1.21-3.23-.12-.31-.53-1.54.12-3.19 0 0 .99-.33 3.25 1.23a11.01 11.01 0 0 1 5.9 0c2.26-1.56 3.25-1.23 3.25-1.23.65 1.65.24 2.88.12 3.19.76.84 1.21 1.91 1.21 3.23 0 4.63-2.75 5.64-5.37 5.95.42.38.8 1.11.8 2.23v3.31c0 .31.21.69.81.57a11.8 11.8 0 0 0 8.02-11.19A11.5 11.5 0 0 0 12 .5Z"/>
          </svg>
        </a>
      </div>
    </nav>
  );
};

export default LandingHeader;