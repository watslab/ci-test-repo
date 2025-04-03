# 使用 Java 基础镜像
FROM openjdk:17-jdk-slim

# 设置工作目录
WORKDIR /app

# 复制项目的 pom.xml 文件
COPY pom.xml .

# 创建 Maven 配置文件并指定阿里云镜像源
RUN mkdir -p /root/.m2 && \
    echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" \
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
             xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd"> \
            <mirrors> \
                <mirror> \
                    <id>aliyunmaven</id> \
                    <mirrorOf>*</mirrorOf> \
                    <name>阿里云公共仓库</name> \
                    <url>https://maven.aliyun.com/repository/public</url> \
                </mirror> \
            </mirrors> \
        </settings>' > /root/.m2/settings.xml

# 备份并替换 sources.list 文件为阿里云镜像源
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
# 下载项目依赖
RUN apt-get update && apt-get install -y maven
RUN mvn dependency:go-offline -DskipTests

# 复制项目源代码
COPY src ./src

# 打包项目
RUN mvn clean package -DskipTests

# 删除除 fat jar 之外的其他工程文件
RUN find . -type f ! -name 'starter-1.0.0-SNAPSHOT-fat.jar' -delete && \
    find . -type d ! -name 'target' -delete

# 暴露端口
EXPOSE 80

# 运行应用
CMD ["java", "-jar", "target/starter-1.0.0-SNAPSHOT-fat.jar"]