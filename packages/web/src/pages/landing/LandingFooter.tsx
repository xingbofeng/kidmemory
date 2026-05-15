import React from 'react';

const LandingFooter: React.FC = () => {
  return (
    <footer className="footer page">
      <h2>KidMemory</h2>
      <p>
        <span data-i18n="footer">A local-first AI publishing system for family memory.</span>{' '}
        <a href="https://github.com/xingbofeng/kidmemory" target="_blank" rel="noreferrer">
          GitHub
        </a>
      </p>
    </footer>
  );
};

export default LandingFooter;