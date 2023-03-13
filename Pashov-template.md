# Introduction

A time-boxed security review of the **protocol name** protocol was done by **pashov**, with a focus on the security aspects of the application's implementation.

# Disclaimer

A smart contract security review can never verify the complete absence of vulnerabilities. This is a time, resource and expertise bound effort where I try to find as many vulnerabilities as possible. I can not guarantee 100% security after the review or even if the review will find any problems with your smart contracts.

# About **pashov**

Krum Pashov, or **pashov**, is an independent smart contract security researcher. Having found numerous security vulnerabilities in various protocols, he does his best to contribute to the blockchain ecosystem and its protocols by putting time and effort into security research & reviews. Reach out on Twitter [@pashovkrum](https://twitter.com/pashovkrum)

# About **ProtocolName**

_explanation what the protocol does, some architectural comments, technical documentation_

## Unexpected/Interesting Design choices

# Threat Model

## Roles & Actors

## Security Interview

**Q:** What in the protocol has value in the market?

**A:**

**Q:** What is the worst thing that can happen to the protocol?

**A:**

**Q:** In what case can the protocol/users lose money?

**A:**

## Potential attacker's goals

## Potential ways for the attacker to achieve his goals

- value transfer functions
- incorrect input from `external` methods with no access control
- incorrect input from external calls to other smart contracts
- calling contract functions in weird sequences

# Severity classification

| Severity               | Impact: High | Impact: Medium | Impact: Low |
| ---------------------- | ------------ | -------------- | ----------- |
| **Likelihood: High**   | Critical     | High           | Medium      |
| **Likelihood: Medium** | High         | Medium         | Low         |
| **Likelihood: Low**    | Medium       | Low            | Low         |

**Impact** - the technical, economic and reputation damage of a successful attack

**Likelihood** - the chance that a particular vulnerability gets discovered and exploited

**Severity** - the overall criticality of the risk

# Security Assessment Summary

**_review commit hash_ - [fffffffff](url)**

### Scope

The following smart contracts were in scope of the audit:

- `SmartContractName`
- `SmartContractName`

The following number of issues were found, categorized by their severity:

- Critical & High: x issues
- Medium: x issues
- Low: x issues
- Informational: x issues

---

# Findings Summary

| ID     | Title                        | Severity      |
| ------ | ---------------------------- | ------------- |
| [C-01] | Any Critical Title Here      | Critical      |
| [H-01] | Any High Title Here          | High          |
| [M-01] | Any Medium Title Here        | Medium        |
| [L-01] | Any Low Title Here           | Low           |
| [I-01] | Any Informational Title Here | Informational |

# Detailed Findings

# [S-01] {name}

## Severity

**Impact:**

**Likelihood:**

## Description

## Recommendations
