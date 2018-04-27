-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 27-04-2018 a las 13:28:02
-- Versión del servidor: 5.6.39-cll-lve
-- Versión de PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `griantmx_dbrcv`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE PROCEDURE `MEDICO_GET_SP` (IN `medico` INT)  BEGIN
	SELECT 
		idMedico,
		med_nombre,
		med_apellidos,
		med_email,
		med_cedula
	FROM medico WHERE idMedico = medico;
END$$

CREATE PROCEDURE `MEDICO_LOGIN_SP` (IN `email` VARCHAR(80) CHARSET utf8, IN `pass` VARCHAR(80) CHARSET utf8)  BEGIN
	DECLARE medico INT;
    
	IF EXISTS( SELECT idMedico FROM medico WHERE med_email = email ) THEN
		SET medico = (SELECT idMedico FROM medico WHERE med_email = email AND med_pass = pass);
        
        IF( medico IS NULL ) THEN
			SELECT 0 as success, 'La contrase&ntilde;a no es v&aacute;lida.' as msg, 109 as code;
        ELSE
			SELECT 1 as success, 'Usuario encontrado.' as msg, medico as idMedico;
        END IF;        
    ELSE
		SELECT 0 as success, 'El email que proporciona no se encontro.' as msg, 110 as code;
    END IF;
END$$

CREATE PROCEDURE `MEDICO_RECOVERYPASS_SP` (IN `email` VARCHAR(250) CHARSET utf8)  BEGIN
	DECLARE pass VARCHAR(150);
    IF EXISTS(SELECT idMedico FROM medico WHERE med_email = email) THEN
		SET pass = ( SELECT med_pass FROM medico WHERE med_email = email );
        -- UPDATE medico SET med_pass = pass WHERE med_email = email;
        SELECT 1 as success, pass as password;
    ELSE 
		SELECT 0 as success, 'El email que proporciono no esta registrado.' as msg, 201 as code;
    END IF;
END$$

CREATE PROCEDURE `MEDICO_REGISTRO_SP` (IN `nombre` VARCHAR(80) CHARSET utf8, IN `apellidos` VARCHAR(80) CHARSET utf8, IN `email` VARCHAR(80) CHARSET utf8, IN `pass` VARCHAR(80) CHARSET utf8, IN `cedula` NUMERIC(10))  BEGIN
	DECLARE existEmail INT;
    DECLARE existCedula INT;
	SET existEmail = (SELECT idMedico FROM medico WHERE med_email = email LIMIT 1);
    
    IF( existEmail IS NULL) THEN 
		SET existCedula = (SELECT idMedico FROM medico WHERE med_cedula = cedula LIMIT 1);
        IF( existCedula IS NULL) THEN 
			INSERT INTO medico (med_nombre, med_apellidos, med_email, med_pass, med_cedula)
            VALUES(nombre, apellidos, email, pass, cedula);
			SELECT 1 AS success, 'Se ha registrado con &eacute;xito.' as msg, LAST_INSERT_ID() as idMedico;
        ELSE
			SELECT 0 AS success, 'La c&eacute;dula que ha proporcionado ya esta registrada.' as msg, 108 as code;
		END IF;        
    ELSE
		SELECT 0 AS success, 'El correo que esta usando ya se encuentra registrado.' as msg, 107 as code;
    END IF;
END$$

CREATE PROCEDURE `NOT_EDITAR_SP` (IN `noticia` INT, IN `titulo` VARCHAR(300) CHARSET utf8, IN `subtitulo` VARCHAR(500) CHARSET utf8, IN `contenido` TEXT CHARSET utf8, IN `imagen` VARCHAR(400) CHARSET utf8, IN `url` VARCHAR(400) CHARSET utf8)  BEGIN
	IF( imagen = '' ) THEN 
		UPDATE noticia SET 
			not_titulo = titulo,
			not_subtitulo = subtitulo,
			not_contenido = contenido,
			not_url = url
		WHERE idNoticia = noticia;   
    ELSE
		UPDATE noticia SET 
			not_titulo = titulo,
			not_subtitulo = subtitulo,
			not_contenido = contenido,
			not_imagen = imagen,
			not_url = url
		WHERE idNoticia = noticia;   
    END IF;
	
    
    SELECT 1 as success, concat('Se ha actualizado correctamente [',imagen) as msg;
END$$

CREATE PROCEDURE `NOT_ELIMINAR_SP` (IN `noticia` INT)  BEGIN
	UPDATE noticia SET not_estatus = 0 WHERE idNoticia = noticia;
    SELECT 1 as success;
END$$

CREATE PROCEDURE `NOT_GETALL_SP` ()  BEGIN
	SELECT 
		idNoticia,
        not_titulo,
        not_subtitulo,
        not_contenido,
        CONCAT('restapi/files/images/', not_imagen) as not_imagen,
        not_url
    FROM noticia WHERE not_estatus = 1
    ORDER BY idNoticia DESC;
END$$

CREATE PROCEDURE `NOT_NUEVA_SP` (IN `titulo` VARCHAR(300) CHARSET utf8, IN `subtitulo` VARCHAR(500) CHARSET utf8, IN `contenido` TEXT CHARSET utf8, IN `imagen` VARCHAR(400) CHARSET utf8, IN `url` VARCHAR(400) CHARSET utf8)  BEGIN
	INSERT INTO noticia (not_titulo, not_subtitulo, not_contenido, not_imagen, not_url)
    VALUE( titulo, subtitulo, contenido, imagen, url );
    
    SELECT 1 as success, 'Se ha insertado correctamente' as msg;
END$$

CREATE PROCEDURE `NOT_TODAS_SP` ()  BEGIN
	SELECT 
		idNoticia,
        not_titulo,
        not_subtitulo,
        not_contenido,
        CONCAT('http://griant.mx/calculadora/restapi/files/images/', not_imagen) as not_imagen,
        not_url,
        CONCAT( DAY(not_fecha)," ", CASE MONTH(`not_fecha`) 
    	WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
    END, ", ", YEAR(not_fecha)) not_fecha
    FROM noticia WHERE not_estatus = 1
    ORDER BY idNoticia DESC;
END$$

CREATE PROCEDURE `REGISTRO_NUEVO_SP` (IN `medico` INT, IN `resultado` VARCHAR(220) CHARSET utf8)  BEGIN
	IF EXISTS( SELECT idMedico FROM medico WHERE idMedico = medico ) THEN
		INSERT INTO resultado(idMedico, res_resultado, res_fecha) VALUES (medico, resultado, CURRENT_TIMESTAMP());
		SELECT 1 as success, 'Se ha insertado un nuevo registro' as msg;
    ELSE 
		SELECT 0 as success, 'El idnetificador del M&eacute;dico no esta registrado.' as msg, 301 as code;
    END IF;	
END$$

CREATE PROCEDURE `USER_CAMBIAPASS_SP` (IN `usuario` INT, IN `pass` VARCHAR(500) CHARSET utf8, IN `passnew` VARCHAR(500) CHARSET utf8, IN `passnewconfirm` VARCHAR(500) CHARSET utf8)  BEGIN
	IF EXISTS( SELECT * FROM usuario WHERE idUsuario = usuario AND usu_pass = MD5(pass) ) THEN
		IF( passnew = passnewconfirm ) THEN
			UPDATE usuario SET usu_pass = MD5(passnewconfirm) WHERE idUsuario = 1;
            SELECT 1 AS success;
        ELSE
			SELECT 0 AS success, 410 as code;
        END IF;		
    ELSE
		SELECT 0 AS success, 400 as code;
    END IF;    
END$$

CREATE PROCEDURE `USER_EDIT_SP` (IN `usuario` INT, IN `nombre` VARCHAR(500) CHARSET utf8, IN `email` VARCHAR(500) CHARSET utf8)  BEGIN
	UPDATE usuario SET usu_nombre = nombre, usu_email = email WHERE idUsuario = usuario;
    SELECT 1 as success;
END$$

CREATE PROCEDURE `USER_GET_SP` (IN `usuario` INT)  BEGIN
	SELECT idUsuario, usu_nombre, usu_email FROM usuario WHERE idUsuario = usuario;
END$$

CREATE PROCEDURE `USER_LOGIN_SP` (IN `email` VARCHAR(150) CHARSET utf8, IN `pass` VARCHAR(200) CHARSET utf8)  BEGIN
	DECLARE usuario INT;
    
	IF EXISTS( SELECT * FROM usuario WHERE usu_email = email ) THEN 
		SET usuario = (SELECT idUsuario FROM usuario WHERE usu_email = email AND usu_pass = MD5(pass));
        
        IF( usuario IS NULL ) THEN
			SELECT 0 as success, 410 as code;
        ELSE
			SELECT 1 as success, 200 as code, usuario as LastId;
        END IF;
    ELSE
		SELECT 0 as success, 400 as code;
    END IF;
END$$

CREATE PROCEDURE `USER_RECOVERYPASS_SP` (IN `email` VARCHAR(250) CHARSET utf8, IN `pass` VARCHAR(50) CHARSET utf8)  BEGIN
    IF EXISTS(SELECT idUsuario FROM usuario WHERE usu_email = email) THEN
        UPDATE usuario SET usu_pass = MD5(pass) WHERE usu_email = email;
        SELECT 1 as success;
    ELSE 
		SELECT 0 as success, 'El email que proporciono no esta registrado.' as msg, 201 as code;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `medico`
--

CREATE TABLE `medico` (
  `idMedico` int(11) NOT NULL,
  `med_nombre` varchar(80) DEFAULT NULL,
  `med_apellidos` varchar(160) DEFAULT NULL,
  `med_email` varchar(150) DEFAULT NULL,
  `med_pass` varchar(100) DEFAULT NULL,
  `med_cedula` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `medico`
--

INSERT INTO `medico` (`idMedico`, `med_nombre`, `med_apellidos`, `med_email`, `med_pass`, `med_cedula`) VALUES
(5, 'Alejandro', 'Grijalva Antonio', 'alex9abril@gmail.com', 'estesEsMipass', '123456789'),
(6, 'Omar', 'Olvera hernande&lt;', 'caligul@live.com.mx', '332b6040', '12345678'),
(7, 'Alan', 'Alan', 'parson@hotmail.com', 'qwerty', '78568923'),
(8, 'Marco', 'Marco', 'Marquito@gmail.com', 'qwerty', '76564567'),
(9, 'Hola', 'Hola', 'hola@hello.mx', 'qwerty', '12345432'),
(10, 'Pedro', 'Pedro', 'pedro@hello.mx', 'qwerty', '987656876'),
(11, 'hola@holjljljlj.com', 'hola@holjljljlj.com', 'oijkjdoads@homail.com', 'qwerty', '35456778'),
(12, 'dasdasdas', 'dasdasdas', 'sddasdasd@hotmail.com', 'qwerty', '34567534'),
(13, 'asdasd123123', 'asdasd123123', 'asdasdads@hotmail.com', 'qwerty', '45332345'),
(14, 'Mike', 'Mike', 'hola@jeje.com', 'qwerty', '76546723'),
(15, 'Tyson', 'Tyson', 'mikaos@holljll.com', 'qwerty', '45984356'),
(16, 'asdasdasd', 'asdasdasd', 'io0iouyioytouy8@hotmail.com', 'qwerty', '98798787'),
(17, 'asdasasdas', 'asdasasdas', 'asdasdasas@gmail.net', 'qwerty', '454534534'),
(18, 'aaaaaaaa', 'aaaaaaaa', 'ggggggg@net.net', 'qwerty', '12321232'),
(19, 'Hola', 'Hola', 'hoapjojio@net.not', 'qwerty', '90809808'),
(20, 'asdasdasdasadsaads', 'asdasdasdasadsaads', 'ouhyioioo@9u00909.net', 'qwerty', '98098902'),
(21, 'asdasdasdasd32213123', 'asdasdasdasd32213123', 'qweqweasdasdas@hotmail.com', 'qwerty', '90878634'),
(22, 'adsasdasdasdas', 'adsasdasdasdas', 'asdasdasdasdasdasdasd@hotajsd.netasijasdiasdji', 'qwerty', '12345345'),
(23, 'Omar', 'Olvera hernande&lt;', 'caligula@live.com.mx', 'qwerty', '12545678'),
(24, 'Omar', 'Olvera hernande&lt;', 'caligula5@live.com.mx', 'qwerty', '16545678'),
(25, 'dsasdasdasd', 'dsasdasdasd', 'rrrriyrriyriur@uuuiu.com', 'qwerty', '87835234'),
(26, 'asdasdasdasdasda', 'asdasdasdasdasda', 'qweqne@net.ent', 'qwerty', '43525456'),
(27, 'vxvcvxcvxcv', 'vxvcvxcvxcv', 'ljdldfjkadf@net.com', 'qwerty', '54656567'),
(28, 'Angel', 'Angel', 'hola@hotmail.com', 'qwerty', '9809887'),
(29, 'klajdloajsdoasdoi', 'klajdloajsdoasdoi', 'buenas@gmail.com', 'qwerty', '980998878'),
(30, 'Ivan', 'Ivan', 'helloteam.ivan@gmail.com', '2bd7e189', '34567845'),
(31, 'Ahsjajaj', 'Ahsjajaj', 'caligil@live.com.mx', 'qwerty', '17381738'),
(32, 'Hgfc', 'Hgfc', 'a@a.mx', '123', '10000001'),
(33, 'omar', 'omar', 'cali@live.com.mx', 'dhfiuahiu', '12345687'),
(34, 'omar', 'omar', 'a@gmail.com', '12345', '12345679'),
(35, 'Bbjn', 'Bbjn', 'Bannanan@vhb.mx', 'q', '12344876'),
(36, 'Bbb', 'Bbb', 'Nnn@jgava.con', '1', '17889003'),
(37, 'Katia', 'Katia', 'Katia.espino@hellomexico.mx', 'magic', '1426382'),
(38, 'Alejandro', 'Grijalva Antonio', 'alex@gmail.com', 'qwerty', '12395687'),
(39, 'Julio', 'Julio', 'helloteam.julio@gmail.com', 'ferrer', '1234567');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `noticia`
--

CREATE TABLE `noticia` (
  `idNoticia` int(11) NOT NULL,
  `not_titulo` varchar(300) DEFAULT NULL,
  `not_subtitulo` varchar(500) DEFAULT NULL,
  `not_contenido` text,
  `not_imagen` varchar(400) DEFAULT NULL,
  `not_url` varchar(400) DEFAULT NULL,
  `not_estatus` int(11) NOT NULL DEFAULT '1',
  `not_fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `noticia`
--

INSERT INTO `noticia` (`idNoticia`, `not_titulo`, `not_subtitulo`, `not_contenido`, `not_imagen`, `not_url`, `not_estatus`, `not_fecha`) VALUES
(1, 'Titulo principal 1', 'Subtitulo de noticia', '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque varius nunc ac lorem convallis euismod. Vestibulum ultricies ipsum felis, ut efficitur ligula varius aliquam. Curabitur ac turpis ligula. Sed ut justo magna. Morbi in ullamcorper ex. Cras nec ipsum quis ante luctus malesuada. Nullam vitae dui nisl. Phasellus vel ipsum lacus. Phasellus feugiat nulla id finibus molestie. Sed mi metus, egestas nec luctus varius, aliquam sit amet leo. Ut quis lectus nisi. Nunc vel purus nec ipsum pellentesque sodales non eget ex. Sed mollis augue libero, sed ullamcorper ante viverra non. Suspendisse dapibus egestas pharetra. Duis elit magna, porttitor eu tellus sed, iaculis interdum mi. Mauris sodales purus ut nulla consectetur dapibus.</p><p>Ut fringilla turpis cursus est lobortis scelerisque. Etiam lobortis nec tellus in fermentum. Praesent efficitur felis at lacus congue, id finibus nulla blandit. Nunc eget urna auctor ligula volutpat egestas. In vitae purus hendrerit quam rutrum efficitur et id ex. In in auctor nisi. Suspendisse potenti. Nullam luctus aliquet turpis, eu gravida ligula finibus eget. Nam in mollis libero. Phasellus sed accumsan arcu, a lacinia enim. In hac habitasse platea dictumst.</p><p>Nunc dignissim sagittis ex quis euismod. Proin vulputate, est sed tristique lobortis, ligula felis vestibulum nulla, eget malesuada velit est eu lectus. Curabitur consectetur aliquet turpis quis bibendum. Pellentesque sodales tortor nec sapien vestibulum dignissim. Proin arcu libero, aliquet at pulvinar condimentum, varius ut quam. Curabitur ut mi tellus. Nulla tincidunt, risus ac consequat bibendum, lectus urna accumsan arcu, eget facilisis urna eros sed turpis. Integer sed velit pretium, maximus elit auctor, euismod justo. In hac habitasse platea dictumst. Morbi feugiat, arcu at laoreet mattis, est elit dapibus metus, ac ornare est quam sit amet dolor. Nunc quis egestas leo, ut tincidunt ipsum. Donec vitae ornare elit, in tincidunt libero.</p>', 'Crisantemo.jpg', 'http://hellomexico.mx/', 1, '2018-04-16 13:42:04'),
(2, 'Titulo principal 2', 'Subtitulo de noticia', '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque varius nunc ac lorem convallis euismod. Vestibulum ultricies ipsum felis, ut efficitur ligula varius aliquam. Curabitur ac turpis ligula. Sed ut justo magna. Morbi in ullamcorper ex. Cras nec ipsum quis ante luctus malesuada. Nullam vitae dui nisl. Phasellus vel ipsum lacus. Phasellus feugiat nulla id finibus molestie. Sed mi metus, egestas nec luctus varius, aliquam sit amet leo. Ut quis lectus nisi. Nunc vel purus nec ipsum pellentesque sodales non eget ex. Sed mollis augue libero, sed ullamcorper ante viverra non. Suspendisse dapibus egestas pharetra. Duis elit magna, porttitor eu tellus sed, iaculis interdum mi. Mauris sodales purus ut nulla consectetur dapibus.</p><p>Ut fringilla turpis cursus est lobortis scelerisque. Etiam lobortis nec tellus in fermentum. Praesent efficitur felis at lacus congue, id finibus nulla blandit. Nunc eget urna auctor ligula volutpat egestas. In vitae purus hendrerit quam rutrum efficitur et id ex. In in auctor nisi. Suspendisse potenti. Nullam luctus aliquet turpis, eu gravida ligula finibus eget. Nam in mollis libero. Phasellus sed accumsan arcu, a lacinia enim. In hac habitasse platea dictumst.</p><p>Nunc dignissim sagittis ex quis euismod. Proin vulputate, est sed tristique lobortis, ligula felis vestibulum nulla, eget malesuada velit est eu lectus. Curabitur consectetur aliquet turpis quis bibendum. Pellentesque sodales tortor nec sapien vestibulum dignissim. Proin arcu libero, aliquet at pulvinar condimentum, varius ut quam. Curabitur ut mi tellus. Nulla tincidunt, risus ac consequat bibendum, lectus urna accumsan arcu, eget facilisis urna eros sed turpis. Integer sed velit pretium, maximus elit auctor, euismod justo. In hac habitasse platea dictumst. Morbi feugiat, arcu at laoreet mattis, est elit dapibus metus, ac ornare est quam sit amet dolor. Nunc quis egestas leo, ut tincidunt ipsum. Donec vitae ornare elit, in tincidunt libero.</p>', 'Desierto.jpg', 'http://hellomexico.mx/', 1, '2018-04-16 13:42:04'),
(3, 'Titulo principal 3', 'Subtitulo de noticia', '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque varius nunc ac lorem convallis euismod. Vestibulum ultricies ipsum felis, ut efficitur ligula varius aliquam. Curabitur ac turpis ligula. Sed ut justo magna. Morbi in ullamcorper ex. Cras nec ipsum quis ante luctus malesuada. Nullam vitae dui nisl. Phasellus vel ipsum lacus. Phasellus feugiat nulla id finibus molestie. Sed mi metus, egestas nec luctus varius, aliquam sit amet leo. Ut quis lectus nisi. Nunc vel purus nec ipsum pellentesque sodales non eget ex. Sed mollis augue libero, sed ullamcorper ante viverra non. Suspendisse dapibus egestas pharetra. Duis elit magna, porttitor eu tellus sed, iaculis interdum mi. Mauris sodales purus ut nulla consectetur dapibus.</p><p>Ut fringilla turpis cursus est lobortis scelerisque. Etiam lobortis nec tellus in fermentum. Praesent efficitur felis at lacus congue, id finibus nulla blandit. Nunc eget urna auctor ligula volutpat egestas. In vitae purus hendrerit quam rutrum efficitur et id ex. In in auctor nisi. Suspendisse potenti. Nullam luctus aliquet turpis, eu gravida ligula finibus eget. Nam in mollis libero. Phasellus sed accumsan arcu, a lacinia enim. In hac habitasse platea dictumst.</p><p>Nunc dignissim sagittis ex quis euismod. Proin vulputate, est sed tristique lobortis, ligula felis vestibulum nulla, eget malesuada velit est eu lectus. Curabitur consectetur aliquet turpis quis bibendum. Pellentesque sodales tortor nec sapien vestibulum dignissim. Proin arcu libero, aliquet at pulvinar condimentum, varius ut quam. Curabitur ut mi tellus. Nulla tincidunt, risus ac consequat bibendum, lectus urna accumsan arcu, eget facilisis urna eros sed turpis. Integer sed velit pretium, maximus elit auctor, euismod justo. In hac habitasse platea dictumst. Morbi feugiat, arcu at laoreet mattis, est elit dapibus metus, ac ornare est quam sit amet dolor. Nunc quis egestas leo, ut tincidunt ipsum. Donec vitae ornare elit, in tincidunt libero.</p>', 'Hortensias.jpg', 'http://hellomexico.mx/', 1, '2018-04-16 13:42:04'),
(4, 'Titulo principal 4', 'Subtitulo de noticia', '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque varius nunc ac lorem convallis euismod. Vestibulum ultricies ipsum felis, ut efficitur ligula varius aliquam. Curabitur ac turpis ligula. Sed ut justo magna. Morbi in ullamcorper ex. Cras nec ipsum quis ante luctus malesuada. Nullam vitae dui nisl. Phasellus vel ipsum lacus. Phasellus feugiat nulla id finibus molestie. Sed mi metus, egestas nec luctus varius, aliquam sit amet leo. Ut quis lectus nisi. Nunc vel purus nec ipsum pellentesque sodales non eget ex. Sed mollis augue libero, sed ullamcorper ante viverra non. Suspendisse dapibus egestas pharetra. Duis elit magna, porttitor eu tellus sed, iaculis interdum mi. Mauris sodales purus ut nulla consectetur dapibus.</p><p>Ut fringilla turpis cursus est lobortis scelerisque. Etiam lobortis nec tellus in fermentum. Praesent efficitur felis at lacus congue, id finibus nulla blandit. Nunc eget urna auctor ligula volutpat egestas. In vitae purus hendrerit quam rutrum efficitur et id ex. In in auctor nisi. Suspendisse potenti. Nullam luctus aliquet turpis, eu gravida ligula finibus eget. Nam in mollis libero. Phasellus sed accumsan arcu, a lacinia enim. In hac habitasse platea dictumst.</p><p>Nunc dignissim sagittis ex quis euismod. Proin vulputate, est sed tristique lobortis, ligula felis vestibulum nulla, eget malesuada velit est eu lectus. Curabitur consectetur aliquet turpis quis bibendum. Pellentesque sodales tortor nec sapien vestibulum dignissim. Proin arcu libero, aliquet at pulvinar condimentum, varius ut quam. Curabitur ut mi tellus. Nulla tincidunt, risus ac consequat bibendum, lectus urna accumsan arcu, eget facilisis urna eros sed turpis. Integer sed velit pretium, maximus elit auctor, euismod justo. In hac habitasse platea dictumst. Morbi feugiat, arcu at laoreet mattis, est elit dapibus metus, ac ornare est quam sit amet dolor. Nunc quis egestas leo, ut tincidunt ipsum. Donec vitae ornare elit, in tincidunt libero.</p>', 'Medusa.jpg', 'http://hellomexico.mx/', 1, '2018-04-16 13:42:04'),
(5, 'Titulo principal 5', 'Subtitulo de noticia', '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque varius nunc ac lorem convallis euismod. Vestibulum ultricies ipsum felis, ut efficitur ligula varius aliquam. Curabitur ac turpis ligula. Sed ut justo magna. Morbi in ullamcorper ex. Cras nec ipsum quis ante luctus malesuada. Nullam vitae dui nisl. Phasellus vel ipsum lacus. Phasellus feugiat nulla id finibus molestie. Sed mi metus, egestas nec luctus varius, aliquam sit amet leo. Ut quis lectus nisi. Nunc vel purus nec ipsum pellentesque sodales non eget ex. Sed mollis augue libero, sed ullamcorper ante viverra non. Suspendisse dapibus egestas pharetra. Duis elit magna, porttitor eu tellus sed, iaculis interdum mi. Mauris sodales purus ut nulla consectetur dapibus.</p><p>Ut fringilla turpis cursus est lobortis scelerisque. Etiam lobortis nec tellus in fermentum. Praesent efficitur felis at lacus congue, id finibus nulla blandit. Nunc eget urna auctor ligula volutpat egestas. In vitae purus hendrerit quam rutrum efficitur et id ex. In in auctor nisi. Suspendisse potenti. Nullam luctus aliquet turpis, eu gravida ligula finibus eget. Nam in mollis libero. Phasellus sed accumsan arcu, a lacinia enim. In hac habitasse platea dictumst.</p><p>Nunc dignissim sagittis ex quis euismod. Proin vulputate, est sed tristique lobortis, ligula felis vestibulum nulla, eget malesuada velit est eu lectus. Curabitur consectetur aliquet turpis quis bibendum. Pellentesque sodales tortor nec sapien vestibulum dignissim. Proin arcu libero, aliquet at pulvinar condimentum, varius ut quam. Curabitur ut mi tellus. Nulla tincidunt, risus ac consequat bibendum, lectus urna accumsan arcu, eget facilisis urna eros sed turpis. Integer sed velit pretium, maximus elit auctor, euismod justo. In hac habitasse platea dictumst. Morbi feugiat, arcu at laoreet mattis, est elit dapibus metus, ac ornare est quam sit amet dolor. Nunc quis egestas leo, ut tincidunt ipsum. Donec vitae ornare elit, in tincidunt libero.</p>', 'Koala.jpg', 'http://hellomexico.mx/', 1, '2018-04-16 13:42:04'),
(6, 'Titulo principal 6', 'Subtitulo de noticia', '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque varius nunc ac lorem convallis euismod. Vestibulum ultricies ipsum felis, ut efficitur ligula varius aliquam. Curabitur ac turpis ligula. Sed ut justo magna. Morbi in ullamcorper ex. Cras nec ipsum quis ante luctus malesuada. Nullam vitae dui nisl. Phasellus vel ipsum lacus. Phasellus feugiat nulla id finibus molestie. Sed mi metus, egestas nec luctus varius, aliquam sit amet leo. Ut quis lectus nisi. Nunc vel purus nec ipsum pellentesque sodales non eget ex. Sed mollis augue libero, sed ullamcorper ante viverra non. Suspendisse dapibus egestas pharetra. Duis elit magna, porttitor eu tellus sed, iaculis interdum mi. Mauris sodales purus ut nulla consectetur dapibus.</p><p>Ut fringilla turpis cursus est lobortis scelerisque. Etiam lobortis nec tellus in fermentum. Praesent efficitur felis at lacus congue, id finibus nulla blandit. Nunc eget urna auctor ligula volutpat egestas. In vitae purus hendrerit quam rutrum efficitur et id ex. In in auctor nisi. Suspendisse potenti. Nullam luctus aliquet turpis, eu gravida ligula finibus eget. Nam in mollis libero. Phasellus sed accumsan arcu, a lacinia enim. In hac habitasse platea dictumst.</p><p>Nunc dignissim sagittis ex quis euismod. Proin vulputate, est sed tristique lobortis, ligula felis vestibulum nulla, eget malesuada velit est eu lectus. Curabitur consectetur aliquet turpis quis bibendum. Pellentesque sodales tortor nec sapien vestibulum dignissim. Proin arcu libero, aliquet at pulvinar condimentum, varius ut quam. Curabitur ut mi tellus. Nulla tincidunt, risus ac consequat bibendum, lectus urna accumsan arcu, eget facilisis urna eros sed turpis. Integer sed velit pretium, maximus elit auctor, euismod justo. In hac habitasse platea dictumst. Morbi feugiat, arcu at laoreet mattis, est elit dapibus metus, ac ornare est quam sit amet dolor. Nunc quis egestas leo, ut tincidunt ipsum. Donec vitae ornare elit, in tincidunt libero.</p>', 'Faro.jpg', 'http://hellomexico.mx/', 1, '2018-04-16 13:42:04'),
(7, 'Titulo principal 7', 'Subtitulo de noticia', '<p>Ã©ipsum dolor sit amet, consectetur adipiscing elit. Quisque varius nunc ac lorem convallis euismod. Vestibulum ultricies ipsum felis, ut efficitur ligula varius aliquam. Curabitur ac turpis ligula. Sed ut justo magna. Morbi in ullamcorper ex. Cras nec ipsum quis ante luctus malesuada. Nullam vitae dui nisl. Phasellus vel ipsum lacus. Phasellus feugiat nulla id finibus molestie. Sed mi metus, egestas nec luctus varius, aliquam sit amet leo. Ut quis lectus nisi. Nunc vel purus nec iv&nbsp; psum pellentesque sodales non eget ex. Sed mollis augue libero, sed ullamcorper ante viverra non. Suspendisse dapibus egestas pharetra. Duis elit magna, porttitor eu tellus sed, iaculis interdum mi. Mauris sodales purus ut nulla consectetur dapibus.</p><p>Ut fringilla turpis cursus est lobortis scelerisque. Etiam lobortis nec tellus in fermentum. Praesent efficitur felis at lacus congue, id finibus nulla blandit. Nunc eget urna auctor ligula volutpat egestas. In vitae purus hendrerit quam rutrum efficitur et id ex. In in auctor nisi. Suspendisse potenti. Nullam luctus aliquet turpis, eu gravida ligula finibus eget. Nam in mollis libero. Phasellus sed accumsan arcu, a lacinia enim. In hac habitasse platea dictumst.</p><p>Nunc dignissim sagittis ex quis euismod. Proin vulputate, est sed tristique lobortis, ligula felis vestibulum nulla, eget malesuada velit est eu lectus. Curabitur consectetur aliquet turpis quis bibendum. Pellentesque sodales tortor nec sapien vestibulum dignissim. Proin arcu libero, aliquet at pulvinar condimentum, varius ut quam. Curabitur ut mi tellus. Nulla tincidunt, risus ac consequat bibendum, lectus urna accumsan arcu, eget facilisis urna eros sed turpis. Integer sed velit pretium, maximus elit auctor, euismod justo. In hac habitasse platea dictumst. Morbi feugiat, arcu at laoreet mattis, est elit dapibus metus, ac ornare est quam sit amet dolor. Nunc quis egestas leo, ut tincidunt ipsum. Donec vitae ornare elit, in tincidunt libero.</p>', '5206_DBX2_SWITCH_WALLPAPER__1920x1080_(1).jpg', 'http://hellomexico.mx/', 1, '2018-04-16 13:42:04'),
(8, 'Titulo principal 8', 'Subtitulo de noticia', '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque varius nunc ac lorem convallis euismod. Vestibulum ultricies ipsum felis, ut efficitur ligula varius aliquam. Curabitur ac turpis ligula. Sed ut justo magna. Morbi in ullamcorper ex. Cras nec ipsum quis ante luctus malesuada. Nullam vitae dui nisl. Phasellus vel ipsum lacus. Phasellus feugiat nulla id finibus molestie. Sed mi metus, egestas nec luctus varius, aliquam sit amet leo. Ut quis lectus nisi. Nunc vel purus nec ipsum pellentesque sodales non eget ex. Sed mollis augue libero, sed ullamcorper ante viverra non. Suspendisse dapibus egestas pharetra. Duis elit magna, porttitor eu tellus sed, iaculis interdum mi. Mauris sodales purus ut nulla consectetur dapibus.</p><p>Ut fringilla turpis cursus est lobortis scelerisque. Etiam lobortis nec tellus in fermentum. Praesent efficitur felis at lacus congue, id finibus nulla blandit. Nunc eget urna auctor ligula volutpat egestas. In vitae purus hendrerit quam rutrum efficitur et id ex. In in auctor nisi. Suspendisse potenti. Nullam luctus aliquet turpis, eu gravida ligula finibus eget. Nam in mollis libero. Phasellus sed accumsan arcu, a lacinia enim. In hac habitasse platea dictumst.</p><p>Nunc dignissim sagittis ex quis euismod. Proin vulputate, est sed tristique lobortis, ligula felis vestibulum nulla, eget malesuada velit est eu lectus. Curabitur consectetur aliquet turpis quis bibendum. Pellentesque sodales tortor nec sapien vestibulum dignissim. Proin arcu libero, aliquet at pulvinar condimentum, varius ut quam. Curabitur ut mi tellus. Nulla tincidunt, risus ac consequat bibendum, lectus urna accumsan arcu, eget facilisis urna eros sed turpis. Integer sed velit pretium, maximus elit auctor, euismod justo. In hac habitasse platea dictumst. Morbi feugiat, arcu at laoreet mattis, est elit dapibus metus, ac ornare est quam sit amet dolor. Nunc quis egestas leo, ut tincidunt ipsum. Donec vitae ornare elit, in tincidunt libero.</p>', 'Tulipanes.jpg', 'http://hellomexico.mx/', 0, '2018-04-16 13:42:04'),
(9, 'NOTICIA #1 Congreso en contra de la diabetes en WTC', 'Congreso diabetes', '<p style=\"margin: 0px 0px 15px; padding: 0px; text-align: justify; color: rgb(0, 0, 0); font-family: &quot;Open Sans&quot;, Arial, sans-serif; font-size: 14px;\">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam accumsan augue dui, nec feugiat ante varius nec. Donec consectetur auctor elit, facilisis dictum urna placerat eget. Morbi viverra congue faucibus. Vivamus mi ex, aliquam vitae nulla dictum, blandit ornare lacus. Vestibulum quis convallis justo, vitae dapibus nibh. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Mauris vitae nisl eget dolor mattis semper sit amet a felis. In odio dolor, cursus dictum orci ut, sollicitudin eleifend arcu. Nulla facilisi. Nullam fermentum interdum sodales. Sed ultricies porttitor urna, id vulputate ipsum sollicitudin ac. Fusce tempor facilisis sapien, quis maximus dolor viverra a. Integer magna ex, ornare vel elit non, condimentum blandit quam. Aenean mollis scelerisque aliquam. Praesent vitae diam sed libero lobortis tempus nec vel dui.</p><p style=\"margin: 0px 0px 15px; padding: 0px; text-align: justify; color: rgb(0, 0, 0); font-family: &quot;Open Sans&quot;, Arial, sans-serif; font-size: 14px;\">Phasellus eleifend leo quis lacus vehicula convallis. Phasellus fermentum fringilla ipsum, laoreet suscipit tellus semper eget. Mauris vestibulum metus mi, sit amet molestie elit rutrum sit amet. Nunc tristique sem ante, et porta diam sagittis ac. Vivamus sit amet ligula eget nisi ornare gravida. Ut a orci id tellus ultricies venenatis. Aliquam urna nunc, gravida id tellus sodales, posuere viverra lorem. Vivamus id diam non nisl consectetur condimentum et ac risus. Sed aliquam tortor eget eros tempus lobortis. Morbi nec elit est. Sed malesuada malesuada orci sit amet rutrum. Sed commodo tempor euismod. Sed eu augue quis erat interdum egestas.</p><p style=\"margin: 0px 0px 15px; padding: 0px; text-align: justify; color: rgb(0, 0, 0); font-family: &quot;Open Sans&quot;, Arial, sans-serif; font-size: 14px;\">Donec sodales justo sem, quis laoreet libero facilisis eget. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus non nunc vitae felis luctus sagittis. Proin ut dui aliquet, feugiat est sodales, tristique elit. Integer ut est accumsan, mollis lorem ut, maximus turpis. Praesent venenatis nibh non suscipit posuere. Proin volutpat, risus sit amet rutrum tempus, purus nisi dignissim massa, nec luctus nisi dui finibus orci.</p><p style=\"margin: 0px 0px 15px; padding: 0px; text-align: justify; color: rgb(0, 0, 0); font-family: &quot;Open Sans&quot;, Arial, sans-serif; font-size: 14px;\">Nullam tincidunt nulla et justo ultrices, id lacinia tortor eleifend. Vivamus lobortis dapibus velit, at bibendum est. Donec iaculis eleifend mauris quis blandit. Phasellus eget consequat sem. Cras efficitur malesuada massa. Curabitur consequat nibh non dui pharetra, vitae dignissim ligula pharetra. Nullam blandit nulla in arcu bibendum ullamcorper. Sed non orci diam. Donec nec finibus risus, sed rutrum ligula. Etiam fringilla metus risus, et cursus tellus luctus at. Duis feugiat sollicitudin ipsum sed imperdiet. Nam enim metus, convallis quis pulvinar ut, efficitur id ipsum. Praesent sodales dolor ac suscipit molestie.</p><p style=\"margin: 0px 0px 15px; padding: 0px; text-align: justify; color: rgb(0, 0, 0); font-family: &quot;Open Sans&quot;, Arial, sans-serif; font-size: 14px;\">Curabitur leo nunc, pretium quis ex non, mattis malesuada nisl. Phasellus rhoncus rhoncus ipsum ut blandit. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec semper ex in maximus facilisis. Morbi leo sem, laoreet ut gravida et, placerat id neque. Curabitur sed velit sed dui tempus vestibulum in sed elit. Nulla mollis ipsum nec convallis lacinia.</p>', '0913_5997e233b92e12606eeecb5a-1-contest.jpg', 'https://es.lipsum.com/feed/html', 0, '2018-04-17 10:09:13'),
(10, 'hello mexico', 'wtc', '<p>esta es una noticia</p>', '0158_SSitios A3.png', 'https://www.google.com/', 1, '2018-04-26 09:01:21');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `resultado`
--

CREATE TABLE `resultado` (
  `idResultado` int(11) NOT NULL,
  `idMedico` int(11) DEFAULT NULL,
  `res_resultado` varchar(220) DEFAULT NULL,
  `res_fecha` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `resultado`
--

INSERT INTO `resultado` (`idResultado`, `idMedico`, `res_resultado`, `res_fecha`) VALUES
(3, 5, 'riesgo alto', '2018-04-13 01:15:28'),
(4, 5, 'riesgo alto', '2018-04-13 02:03:16'),
(5, 5, 'riesgo alto', '2018-04-13 03:30:49'),
(6, 6, 'Riesgo alto', '2018-04-13 11:02:30'),
(7, 6, 'Riesgo alto', '2018-04-13 11:02:32'),
(8, 6, 'Riesgo alto', '2018-04-16 17:05:34'),
(9, 6, 'assets/imgs/v_2.png', '2018-04-16 18:09:56'),
(10, 6, 'assets/imgs/a_5.png', '2018-04-16 19:09:31'),
(11, 6, 'assets/imgs/v_4.png', '2018-04-16 19:16:26'),
(12, 6, 'assets/imgs/v_2.png', '2018-04-16 19:18:29'),
(13, 6, 'assets/imgs/v_2.png', '2018-04-16 19:18:47'),
(14, 6, 'assets/imgs/v_2.png', '2018-04-16 19:19:37'),
(15, 6, 'assets/imgs/v_2.png', '2018-04-16 19:19:49'),
(16, 6, 'assets/imgs/v_2.png', '2018-04-16 19:20:58'),
(17, 6, 'assets/imgs/v_2.png', '2018-04-16 19:22:41'),
(18, 6, 'assets/imgs/v_2.png', '2018-04-16 19:38:55'),
(19, 6, 'assets/imgs/v_2.png', '2018-04-16 19:38:59'),
(20, 6, 'assets/imgs/a_37.png', '2018-04-16 19:52:12'),
(21, 9, 'assets/imgs/v_2.png', '2018-04-17 11:28:41'),
(22, 9, 'assets/imgs/v_2.png', '2018-04-17 11:52:43'),
(23, 9, 'assets/imgs/v_2.png', '2018-04-17 11:52:47'),
(24, 9, 'assets/imgs/v_2.png', '2018-04-17 11:52:56'),
(25, 9, 'assets/imgs/v_2.png', '2018-04-17 12:15:00'),
(26, 9, 'assets/imgs/v_2.png', '2018-04-17 12:16:00'),
(27, 9, 'assets/imgs/v_2.png', '2018-04-17 12:16:02'),
(28, 9, 'assets/imgs/v_2.png', '2018-04-17 12:16:13'),
(29, 9, 'assets/imgs/v_2.png', '2018-04-17 12:16:19'),
(30, 9, 'assets/imgs/v_2.png', '2018-04-17 12:16:24'),
(31, 9, 'assets/imgs/v_2.png', '2018-04-17 12:21:20'),
(32, 9, 'assets/imgs/v_2.png', '2018-04-17 12:22:52'),
(33, 30, 'assets/imgs/v_2.png', '2018-04-17 12:27:05'),
(34, 30, 'assets/imgs/v_2.png', '2018-04-17 12:31:21'),
(35, 30, 'assets/imgs/v_2.png', '2018-04-17 12:32:37'),
(36, 30, 'assets/imgs/v_2.png', '2018-04-17 12:33:03'),
(37, 30, 'assets/imgs/v_2.png', '2018-04-17 12:33:07'),
(38, 30, 'assets/imgs/v_2.png', '2018-04-17 12:33:22'),
(39, 30, 'assets/imgs/v_2.png', '2018-04-17 12:34:34'),
(40, 30, 'assets/imgs/v_2.png', '2018-04-17 12:34:36'),
(41, 30, 'assets/imgs/v_2.png', '2018-04-17 12:34:41'),
(42, 30, 'assets/imgs/v_2.png', '2018-04-17 12:34:48'),
(43, 30, 'assets/imgs/v_2.png', '2018-04-17 12:34:53'),
(44, 30, 'assets/imgs/v_2.png', '2018-04-17 12:35:00'),
(45, 30, 'assets/imgs/v_2.png', '2018-04-17 12:35:07'),
(46, 30, 'assets/imgs/v_2.png', '2018-04-17 12:35:40'),
(47, 30, 'assets/imgs/v_2.png', '2018-04-17 12:35:42'),
(48, 30, 'assets/imgs/v_2.png', '2018-04-17 12:35:44'),
(49, 30, 'assets/imgs/v_2.png', '2018-04-17 12:35:47'),
(50, 30, 'assets/imgs/v_2.png', '2018-04-17 12:35:54'),
(51, 30, 'assets/imgs/v_2.png', '2018-04-17 12:36:39'),
(52, 30, 'assets/imgs/v_2.png', '2018-04-17 12:37:37'),
(53, 6, 'assets/imgs/v_2.png', '2018-04-17 13:10:32'),
(54, 6, 'assets/imgs/v_2.png', '2018-04-17 13:11:44'),
(55, 6, 'assets/imgs/v_2.png', '2018-04-17 13:11:49'),
(56, 6, 'assets/imgs/v_2.png', '2018-04-17 13:11:56'),
(57, 9, 'assets/imgs/v_4.png', '2018-04-17 13:57:07'),
(58, 30, 'assets/imgs/a_10.png', '2018-04-17 14:03:26'),
(59, 6, 'assets/imgs/a_8.png', '2018-04-17 16:40:29'),
(60, 6, 'assets/imgs/v_2.png', '2018-04-17 17:01:55'),
(61, 6, 'assets/imgs/v_2.png', '2018-04-17 17:04:02'),
(62, 6, 'assets/imgs/v_2.png', '2018-04-17 17:05:28'),
(63, 6, 'assets/imgs/v_2.png', '2018-04-17 17:07:15'),
(64, 6, 'assets/imgs/v_2.png', '2018-04-17 17:08:00'),
(65, 6, 'assets/imgs/v_2.png', '2018-04-17 17:10:50'),
(66, 9, 'assets/imgs/a_7.png', '2018-04-17 17:32:28'),
(67, 9, 'assets/imgs/v_2.png', '2018-04-17 17:32:48'),
(68, 9, 'assets/imgs/v_2.png', '2018-04-17 17:32:52'),
(69, 6, 'assets/imgs/v_2.png', '2018-04-17 17:34:27'),
(70, 9, 'assets/imgs/v_2.png', '2018-04-17 17:49:01'),
(71, 6, 'assets/imgs/v_2.png', '2018-04-17 18:46:34'),
(72, 30, 'assets/imgs/a_10.png', '2018-04-17 18:51:32'),
(73, 30, 'assets/imgs/r_45.png', '2018-04-17 18:52:13'),
(74, 30, 'assets/imgs/r_&gt;53.png', '2018-04-17 18:52:27'),
(75, 30, 'assets/imgs/v_2.png', '2018-04-17 18:53:51'),
(76, 6, 'assets/imgs/r_&gt;53.png', '2018-04-18 10:35:02'),
(77, 6, 'assets/imgs/r_53.png', '2018-04-18 10:39:30'),
(78, 6, 'assets/imgs/v_2.png', '2018-04-18 13:09:48'),
(79, 30, 'assets/imgs/a_13.png', '2018-04-18 13:43:10'),
(80, 9, 'assets/imgs/v_2.png', '2018-04-18 16:33:44'),
(81, 9, 'assets/imgs/v_2.png', '2018-04-18 16:33:57'),
(82, 9, 'assets/imgs/v_2.png', '2018-04-18 16:35:46'),
(83, 9, 'assets/imgs/r_10.png', '2018-04-18 18:34:57'),
(84, 37, 'assets/imgs/v_4.png', '2018-04-18 19:02:33'),
(85, 37, 'assets/imgs/v_53.png', '2018-04-18 19:06:00'),
(86, 37, 'assets/imgs/v_53.png', '2018-04-18 19:11:39'),
(87, 37, 'assets/imgs/r_53.png', '2018-04-18 19:13:03'),
(88, 37, 'assets/imgs/v_53.png', '2018-04-18 19:13:23'),
(89, 37, 'assets/imgs/r_53.png', '2018-04-18 19:16:54'),
(90, 37, 'assets/imgs/r_53.png', '2018-04-18 19:16:59'),
(91, 37, 'assets/imgs/r_53.png', '2018-04-18 19:17:04'),
(92, 37, 'assets/imgs/r_53.png', '2018-04-18 19:17:09'),
(93, 37, 'assets/imgs/r_25.png', '2018-04-18 19:17:28'),
(94, 37, 'assets/imgs/v_2.png', '2018-04-18 19:18:59'),
(95, 37, 'assets/imgs/v_2.png', '2018-04-18 19:19:16'),
(96, 37, 'assets/imgs/v_3.png', '2018-04-18 19:19:22'),
(97, 37, 'assets/imgs/v_2.png', '2018-04-19 11:01:07'),
(98, 37, 'assets/imgs/v_2.png', '2018-04-19 11:10:15'),
(99, 37, 'assets/imgs/v_2.png', '2018-04-19 11:10:43'),
(100, 37, 'assets/imgs/v_4.png', '2018-04-19 11:11:08'),
(101, 37, 'assets/imgs/v_2.png', '2018-04-19 11:12:38'),
(102, 37, 'assets/imgs/v_2.png', '2018-04-19 11:14:14'),
(103, 37, 'assets/imgs/v_2.png', '2018-04-19 11:14:32'),
(104, 37, 'assets/imgs/v_4.png', '2018-04-19 11:19:34'),
(105, 37, 'assets/imgs/a_5.png', '2018-04-19 11:21:28'),
(106, 37, 'assets/imgs/a_4.png', '2018-04-19 11:24:08'),
(107, 37, 'assets/imgs/a_4.png', '2018-04-19 11:25:05'),
(108, 37, 'assets/imgs/a_5.png', '2018-04-19 11:27:28'),
(109, 37, 'assets/imgs/a_5.png', '2018-04-19 11:30:19'),
(110, 37, 'assets/imgs/a_7.png', '2018-04-19 11:30:49'),
(111, 37, 'assets/imgs/r_10.png', '2018-04-19 11:31:28'),
(112, 37, 'assets/imgs/r_10.png', '2018-04-19 11:32:13'),
(113, 37, 'assets/imgs/r_10.png', '2018-04-19 11:32:27'),
(114, 37, 'assets/imgs/r_13.png', '2018-04-19 11:32:38'),
(115, 37, 'assets/imgs/r_16.png', '2018-04-19 11:33:16'),
(116, 37, 'assets/imgs/a_10.png', '2018-04-19 11:34:40'),
(117, 37, 'assets/imgs/r_20.png', '2018-04-19 11:35:51'),
(118, 37, 'assets/imgs/r_25.png', '2018-04-19 11:36:13'),
(119, 37, 'assets/imgs/r_31.png', '2018-04-19 11:37:16'),
(120, 37, 'assets/imgs/v_2.png', '2018-04-19 11:39:37'),
(121, 37, 'assets/imgs/v_2.png', '2018-04-19 11:40:55'),
(122, 37, 'assets/imgs/v_2.png', '2018-04-19 11:42:47'),
(123, 37, 'assets/imgs/v_4.png', '2018-04-19 11:43:13'),
(124, 37, 'assets/imgs/a_5.png', '2018-04-19 11:44:52'),
(125, 37, 'assets/imgs/a_7.png', '2018-04-19 11:45:36'),
(126, 37, 'assets/imgs/a_8.png', '2018-04-19 11:47:54'),
(127, 37, 'assets/imgs/r_13.png', '2018-04-19 11:53:40'),
(128, 37, 'assets/imgs/r_13.png', '2018-04-19 11:54:39'),
(129, 37, 'assets/imgs/r_16.png', '2018-04-19 11:55:19'),
(130, 37, 'assets/imgs/r_20.png', '2018-04-19 11:55:42'),
(131, 37, 'assets/imgs/r_25.png', '2018-04-19 11:56:25'),
(132, 37, 'assets/imgs/r_31.png', '2018-04-19 11:57:40'),
(133, 37, 'assets/imgs/r_37.png', '2018-04-19 11:58:13'),
(134, 37, 'assets/imgs/v_2.png', '2018-04-19 12:01:09'),
(135, 37, 'assets/imgs/v_2.png', '2018-04-19 12:01:44'),
(136, 37, 'assets/imgs/v_4.png', '2018-04-19 12:17:15'),
(137, 37, 'assets/imgs/v_5.png', '2018-04-19 12:18:40'),
(138, 37, 'assets/imgs/v_2.png', '2018-04-19 12:19:18'),
(139, 37, 'assets/imgs/a_7.png', '2018-04-19 12:23:28'),
(140, 37, 'assets/imgs/a_8.png', '2018-04-19 12:25:02'),
(141, 37, 'assets/imgs/r_16.png', '2018-04-19 12:25:59'),
(142, 37, 'assets/imgs/a_10.png', '2018-04-19 12:26:17'),
(143, 37, 'assets/imgs/r_16.png', '2018-04-19 12:27:04'),
(144, 37, 'assets/imgs/r_16.png', '2018-04-19 12:27:35'),
(145, 37, 'assets/imgs/r_16.png', '2018-04-19 12:27:42'),
(146, 37, 'assets/imgs/r_16.png', '2018-04-19 12:27:50'),
(147, 37, 'assets/imgs/r_20.png', '2018-04-19 12:28:02'),
(148, 37, 'assets/imgs/r_25.png', '2018-04-19 12:29:28'),
(149, 37, 'assets/imgs/r_31.png', '2018-04-19 12:30:10'),
(150, 37, 'assets/imgs/r_37.png', '2018-04-19 12:30:56'),
(151, 37, 'assets/imgs/r_45.png', '2018-04-19 12:31:45'),
(152, 37, 'assets/imgs/v_2.png', '2018-04-19 12:37:58'),
(153, 37, 'assets/imgs/v_2.png', '2018-04-19 12:39:04'),
(154, 37, 'assets/imgs/v_3.png', '2018-04-19 12:39:44'),
(155, 37, 'assets/imgs/v_7.png', '2018-04-19 12:40:09'),
(156, 37, 'assets/imgs/v_8.png', '2018-04-19 12:41:02'),
(157, 37, 'assets/imgs/a_10.png', '2018-04-19 12:43:31'),
(158, 37, 'assets/imgs/a_13.png', '2018-04-19 12:44:13'),
(159, 37, 'assets/imgs/r_20.png', '2018-04-19 12:45:17'),
(160, 37, 'assets/imgs/r_25.png', '2018-04-19 13:07:04'),
(161, 37, 'assets/imgs/r_31.png', '2018-04-19 13:22:28'),
(162, 37, 'assets/imgs/r_37.png', '2018-04-19 13:22:55'),
(163, 37, 'assets/imgs/r_45.png', '2018-04-19 13:23:20'),
(164, 37, 'assets/imgs/r_53.png', '2018-04-19 13:32:36'),
(165, 37, 'assets/imgs/r_53.png', '2018-04-19 13:33:29'),
(166, 37, 'assets/imgs/r_53.png', '2018-04-19 13:34:54'),
(167, 37, 'assets/imgs/r_45.png', '2018-04-19 13:35:02'),
(168, 37, 'assets/imgs/r_37.png', '2018-04-19 13:38:01'),
(169, 37, 'assets/imgs/r_31.png', '2018-04-19 13:38:45'),
(170, 37, 'assets/imgs/r_25.png', '2018-04-19 13:39:56'),
(171, 37, 'assets/imgs/a_16.png', '2018-04-19 13:40:40'),
(172, 37, 'assets/imgs/a_16.png', '2018-04-19 13:44:39'),
(173, 37, 'assets/imgs/a_13.png', '2018-04-19 13:45:21'),
(174, 37, 'assets/imgs/v_10.png', '2018-04-19 13:46:17'),
(175, 37, 'assets/imgs/v_8.png', '2018-04-19 13:48:29'),
(176, 37, 'assets/imgs/v_4.png', '2018-04-19 13:49:16'),
(177, 37, 'assets/imgs/v_2.png', '2018-04-19 13:50:27'),
(178, 37, 'assets/imgs/v_2.png', '2018-04-19 13:51:11'),
(179, 37, 'assets/imgs/v_2.png', '2018-04-19 13:55:22'),
(180, 37, 'assets/imgs/v_3.png', '2018-04-19 13:56:09'),
(181, 37, 'assets/imgs/v_5.png', '2018-04-19 13:57:07'),
(182, 37, 'assets/imgs/v_10.png', '2018-04-19 13:57:33'),
(183, 37, 'assets/imgs/v_13.png', '2018-04-19 13:58:19'),
(184, 37, 'assets/imgs/a_16.png', '2018-04-19 13:58:57'),
(185, 37, 'assets/imgs/a_20.png', '2018-04-19 13:59:30'),
(186, 37, 'assets/imgs/r_31.png', '2018-04-19 14:00:09'),
(187, 37, 'assets/imgs/a_20.png', '2018-04-19 14:01:17'),
(188, 37, 'assets/imgs/r_31.png', '2018-04-19 14:01:28'),
(189, 37, 'assets/imgs/r_31.png', '2018-04-19 14:01:37'),
(190, 37, 'assets/imgs/r_37.png', '2018-04-19 14:01:44'),
(191, 37, 'assets/imgs/r_45.png', '2018-04-19 14:02:34'),
(192, 37, 'assets/imgs/r_53.png', '2018-04-19 14:03:08'),
(193, 37, 'assets/imgs/r_53.png', '2018-04-19 14:03:31'),
(194, 37, 'assets/imgs/r_53.png', '2018-04-19 14:03:50'),
(195, 37, 'assets/imgs/r_53.png', '2018-04-19 14:04:49'),
(196, 37, 'assets/imgs/r_53.png', '2018-04-19 14:05:48'),
(197, 37, 'assets/imgs/r_53.png', '2018-04-19 14:06:11'),
(198, 16, 'Riesgo alto', '2018-04-19 14:06:17'),
(199, 37, 'assets/imgs/r_45.png', '2018-04-19 14:06:50'),
(200, 37, 'assets/imgs/r_37.png', '2018-04-19 14:08:30'),
(201, 37, 'assets/imgs/r_37.png', '2018-04-19 14:09:02'),
(202, 37, 'assets/imgs/a_25.png', '2018-04-19 14:09:42'),
(203, 37, 'assets/imgs/a_20.png', '2018-04-19 14:10:11'),
(204, 37, 'assets/imgs/v_16.png', '2018-04-19 14:12:38'),
(205, 37, 'assets/imgs/v_7.png', '2018-04-19 14:14:38'),
(206, 37, 'assets/imgs/v_4.png', '2018-04-19 14:15:34'),
(207, 37, 'assets/imgs/v_2.png', '2018-04-19 14:16:26'),
(208, 37, 'assets/imgs/v_3.png', '2018-04-19 14:16:44'),
(209, 37, 'assets/imgs/v_3.png', '2018-04-19 14:17:35'),
(210, 37, 'assets/imgs/v_8.png', '2018-04-19 14:25:37'),
(211, 37, 'assets/imgs/v_20.png', '2018-04-19 14:26:55'),
(212, 37, 'assets/imgs/a_25.png', '2018-04-19 14:27:30'),
(213, 37, 'assets/imgs/a_31.png', '2018-04-19 14:28:44'),
(214, 37, 'assets/imgs/r_45.png', '2018-04-19 14:47:33'),
(215, 37, 'assets/imgs/r_45.png', '2018-04-19 14:49:01'),
(216, 37, 'assets/imgs/r_53.png', '2018-04-19 14:49:09'),
(217, 37, 'assets/imgs/r_53.png', '2018-04-19 14:49:52'),
(218, 37, 'assets/imgs/r_53.png', '2018-04-19 14:52:38'),
(219, 37, 'assets/imgs/r_53.png', '2018-04-19 14:52:48'),
(220, 37, 'assets/imgs/r_53.png', '2018-04-19 14:52:53'),
(221, 37, 'assets/imgs/r_53.png', '2018-04-19 14:53:20'),
(222, 37, 'assets/imgs/r_53.png', '2018-04-19 14:54:07'),
(223, 37, 'assets/imgs/v_53.png', '2018-04-19 14:54:32'),
(224, 37, 'assets/imgs/v_53.png', '2018-04-19 14:55:06'),
(225, 37, 'assets/imgs/v_53.png', '2018-04-19 14:55:30'),
(226, 37, 'assets/imgs/v_53.png', '2018-04-19 14:56:07'),
(227, 37, 'assets/imgs/v_53.png', '2018-04-19 14:56:10'),
(228, 37, 'assets/imgs/v_53.png', '2018-04-19 14:56:42'),
(229, 37, 'assets/imgs/v_53.png', '2018-04-19 14:57:04'),
(230, 37, 'assets/imgs/v_53.png', '2018-04-19 14:57:52'),
(231, 37, 'assets/imgs/v_53.png', '2018-04-19 14:58:18'),
(232, 37, 'assets/imgs/a_37.png', '2018-04-19 15:02:08'),
(233, 37, 'assets/imgs/a_31.png', '2018-04-19 15:08:09'),
(234, 37, 'assets/imgs/a_31.png', '2018-04-19 15:09:30'),
(235, 37, 'assets/imgs/v_25.png', '2018-04-19 15:10:38'),
(236, 37, 'assets/imgs/v_20.png', '2018-04-19 15:11:17'),
(237, 37, 'assets/imgs/v_10.png', '2018-04-19 15:11:40'),
(238, 37, 'assets/imgs/v_7.png', '2018-04-19 15:12:30'),
(239, 37, 'assets/imgs/v_4.png', '2018-04-19 15:12:50'),
(240, 37, 'assets/imgs/r_16.png', '2018-04-19 17:04:35'),
(241, 9, 'assets/imgs/v_2.png', '2018-04-19 17:35:57'),
(242, 9, 'assets/imgs/v_2.png', '2018-04-19 17:35:59'),
(243, 6, 'assets/imgs/v_2.png', '2018-04-19 18:18:19'),
(244, 6, 'assets/imgs/v_2.png', '2018-04-19 18:43:40'),
(245, 6, 'assets/imgs/v_2.png', '2018-04-19 18:46:29'),
(246, 6, 'assets/imgs/v_2.png', '2018-04-19 18:50:10'),
(247, 6, 'assets/imgs/v_3.png', '2018-04-19 18:51:32'),
(248, 6, 'assets/imgs/v_3.png', '2018-04-19 18:52:09'),
(249, 6, 'assets/imgs/v_4.png', '2018-04-19 18:52:38'),
(250, 6, 'assets/imgs/a_5.png', '2018-04-19 18:53:00'),
(251, 6, 'assets/imgs/r_53.png', '2018-04-19 18:54:00'),
(252, 9, 'assets/imgs/a_8.png', '2018-04-19 18:59:44'),
(253, 37, 'assets/imgs/r_53.png', '2018-04-19 19:08:01'),
(254, 37, 'assets/imgs/r_53.png', '2018-04-19 19:09:32'),
(255, 6, 'assets/imgs/v_2.png', '2018-04-19 19:15:08'),
(256, 6, 'assets/imgs/v_2.png', '2018-04-19 19:16:05'),
(257, 6, 'assets/imgs/v_2.png', '2018-04-19 19:16:51'),
(258, 6, 'assets/imgs/v_2.png', '2018-04-19 19:18:16'),
(259, 6, 'assets/imgs/v_2.png', '2018-04-19 19:19:12'),
(260, 37, 'assets/imgs/v_2.png', '2018-04-20 09:08:11'),
(261, 9, 'assets/imgs/v_2.png', '2018-04-26 11:29:36'),
(262, 9, 'assets/imgs/v_2.png', '2018-04-26 11:50:31'),
(263, 9, 'assets/imgs/v_2.png', '2018-04-26 11:51:24'),
(264, 9, 'assets/imgs/v_2.png', '2018-04-26 12:12:38'),
(265, 9, 'assets/imgs/v_2.png', '2018-04-26 12:14:13'),
(266, 9, 'assets/imgs/v_2.png', '2018-04-26 12:16:31'),
(267, 9, 'assets/imgs/v_2.png', '2018-04-26 12:16:47'),
(268, 9, 'assets/imgs/v_2.png', '2018-04-26 12:17:34'),
(269, 9, 'assets/imgs/v_2.png', '2018-04-26 12:28:38'),
(270, 9, 'assets/imgs/v_2.png', '2018-04-26 12:31:47'),
(271, 9, 'assets/imgs/v_2.png', '2018-04-26 12:36:35'),
(272, 9, 'assets/imgs/v_2.png', '2018-04-26 12:54:03'),
(273, 9, 'assets/imgs/v_2.png', '2018-04-26 12:54:45'),
(274, 9, 'assets/imgs/v_2.png', '2018-04-26 12:55:26'),
(275, 9, 'assets/imgs/v_13.png', '2018-04-26 17:53:24'),
(276, 39, 'assets/imgs/v_2.png', '2018-04-26 17:58:18'),
(277, 9, 'assets/imgs/v_2.png', '2018-04-27 12:34:32'),
(278, 9, 'assets/imgs/a_8.png', '2018-04-27 12:36:49'),
(279, 9, 'assets/imgs/v_4.png', '2018-04-27 12:38:40'),
(280, 9, 'assets/imgs/v_2.png', '2018-04-27 12:40:06'),
(281, 9, 'assets/imgs/v_4.png', '2018-04-27 12:40:11');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idUsuario` int(11) NOT NULL,
  `usu_nombre` varchar(250) DEFAULT NULL,
  `usu_email` varchar(150) DEFAULT NULL,
  `usu_pass` varchar(60) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idUsuario`, `usu_nombre`, `usu_email`, `usu_pass`) VALUES
(1, 'Katia Espino', 'alex9abril@gmail.com', 'd8578edf8458ce06fbc5bb76a58c5ca4');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `medico`
--
ALTER TABLE `medico`
  ADD PRIMARY KEY (`idMedico`);

--
-- Indices de la tabla `noticia`
--
ALTER TABLE `noticia`
  ADD PRIMARY KEY (`idNoticia`);

--
-- Indices de la tabla `resultado`
--
ALTER TABLE `resultado`
  ADD PRIMARY KEY (`idResultado`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idUsuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `medico`
--
ALTER TABLE `medico`
  MODIFY `idMedico` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT de la tabla `noticia`
--
ALTER TABLE `noticia`
  MODIFY `idNoticia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `resultado`
--
ALTER TABLE `resultado`
  MODIFY `idResultado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=282;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
