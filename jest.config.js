module.exports = {
  // See: https://github.com/smooth-code/jest-puppeteer
  preset: 'jest-puppeteer',
  verbose: true,
  moduleNameMapper: {
    '^@shared/(.*)$': '<rootDir>/src/shared/$1'
  },
  // testMatch: ['**/?(*.)+(spec|test).[t]s'],
  testPathIgnorePatterns: ['<rootDir>/dist/', '<rootDir>/node_modules/'],
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js', 'jest-extended'],
  transform: {
    '^.+\\.ts?$': 'ts-jest'
  }
}
