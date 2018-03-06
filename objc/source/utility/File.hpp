/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef File_hpp
#define File_hpp

#include <WCDB/Error.hpp>
#include <WCDB/ThreadLocal.hpp>
#include <list>
#include <string>

namespace WCDB {

namespace File {

#pragma mark - Basic
std::pair<bool, bool> isExists(const std::string &path);
std::pair<bool, size_t> getFileSize(const std::string &path);
bool createHardLink(const std::string &from, const std::string &to);
bool removeHardLink(const std::string &path);
bool removeFile(const std::string &path);
bool createDirectory(const std::string &path);

#pragma mark - Combination
std::pair<bool, size_t> getFilesSize(const std::list<std::string> &paths);
bool removeFiles(const std::list<std::string> &paths);
bool moveFiles(const std::list<std::string> &paths,
               const std::string &directory);
bool createDirectoryWithIntermediateDirectories(const std::string &path);

Error getError();

} //namespace File

} //namespace WCDB

#endif /* File_hpp */