/******************************************************************************
MIT License

Copyright (c) 2026 Shashank Obla, Carnegie Mellon University

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
******************************************************************************/

#pragma once

#include <cstddef>
#include <boost/interprocess/sync/interprocess_mutex.hpp>
#include <boost/interprocess/sync/interprocess_condition.hpp>
#include <boost/thread/thread.hpp>
#include <boost/timer/timer.hpp>
#include <boost/call_traits.hpp>
#include <boost/bind.hpp>
#include <vector>
#include <string>
#include <iostream>

template <class T, size_t N>
class bounded_buffer {
 public:
  typedef std::array<T, N> container_type;
  typedef typename container_type::size_type size_type;
  typedef typename container_type::value_type value_type;
  typedef typename boost::call_traits<value_type>::param_type param_type;

  explicit bounded_buffer() : m_head(0), m_tail(0), m_full(false), m_empty(true), m_container() {}

  value_type* peek_front() {
    boost::unique_lock<boost::interprocess::interprocess_mutex> lock(m_mutex);
    m_not_full.wait(lock, boost::bind(&bounded_buffer::is_not_full, this));
    return &m_container[m_tail];
  }

  void push_front() {
    // Atomically update m_unread
    boost::unique_lock<boost::interprocess::interprocess_mutex> lock(m_mutex);
    m_tail = (m_tail + 1) % m_container.size();
    m_empty = false;
    if ((m_tail + 1) % m_container.size() == m_head) {
      m_full = true;
    }
    lock.unlock();
    m_not_empty.notify_one();
  }

  value_type* peek_back() {
    boost::unique_lock<boost::interprocess::interprocess_mutex> lock(m_mutex);
    m_not_empty.wait(lock, boost::bind(&bounded_buffer::is_not_empty, this));
    return &m_container[m_head];
  }

  // Undefined behavior if called without a preceding peek_back()
  void pop_back() {
    boost::unique_lock<boost::interprocess::interprocess_mutex> lock(m_mutex);
    m_head = (m_head + 1) % m_container.size();
    m_full = false;
    if (m_head == m_tail) {
      m_empty = true;
    }
    lock.unlock();
    m_not_full.notify_one();
  }

 private:
  bounded_buffer(const bounded_buffer&) = delete;             // Disabled copy constructor
  bounded_buffer& operator=(const bounded_buffer&) = delete;  // Disabled assign operator

  bool is_not_empty() const { return !m_empty; }
  bool is_not_full() const { return !m_full; }

  size_type m_head, m_tail;
  bool m_full, m_empty;
  container_type m_container;
  boost::interprocess::interprocess_mutex m_mutex;
  boost::interprocess::interprocess_condition m_not_empty;
  boost::interprocess::interprocess_condition m_not_full;
};
